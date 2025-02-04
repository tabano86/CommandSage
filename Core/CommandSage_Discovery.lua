-- =============================================================================
-- CommandSage_Discovery.lua
-- Extended dynamic scanning for 100% command discovery:
--  - Built-in Blizzard commands
--  - Macros (global & character)
--  - Ace (or similar library) registered commands (via macros and via AceConsole if available)
--  - Emotes (hardcoded & global lookup if available)
--  - Help commands (including any command with "help" in its key)
--  - Extra commands (custom table)
--  - Scanning the global environment for any unregistered slash commands
--  - AceConsole scan (if enabled and available)
--  - Custom commands from a global table (if available)
--  - Forced fallback commands
-- =============================================================================

CommandSage_Discovery = {}

local discoveredCommands = {}
local forcedFallback = {
    "/cmdsage", "/cmdsagehistory", "/help", "/?", "/reload", "/console",
    "/dance", "/macro", "/ghelp", "/yell", "/say", "/emote", "/combatlog",
    "/afk", "/dnd", "/camp", "/logout", "/played", "/time", "/script"
}

-- Extra commands defined by the addon developer
local extraCommands = {
    { slash = "/gold", source = "Extra", description = "Display gold across characters",
      callback = function(msg) print("Gold: Feature not implemented yet.") end },
    { slash = "/ping", source = "Extra", description = "Display latency/ping info",
      callback = function(msg) print("Ping: Feature not implemented yet.") end },
    { slash = "/mem", source = "Extra", description = "Display addon memory usage",
      callback = function(msg) print("Memory (KB): " .. collectgarbage("count")) end },
    -- Add more extra commands as needed...
}

-- Helper: insert a discovered command if not already present.
local function addCommand(slash, data)
    local lower = slash:lower()
    if not discoveredCommands[lower] then
        discoveredCommands[lower] = {
            slash       = lower,
            callback    = data.callback,
            source      = data.source or "Unknown",
            description = data.description or "<No description>"
        }
    end
end

-- Forced fallback: add any missing commands from our fallback list.
local function ForceFallbacks()
    for _, slash in ipairs(forcedFallback) do
        local lower = slash:lower()
        if not discoveredCommands[lower] then
            addCommand(lower, {
                callback = function(msg)
                    print("Fallback for " .. slash .. " with args:", msg or "")
                end,
                source = "Fallback",
                description = "Auto-injected fallback command"
            })
        end
    end

    if CommandSage_Config.Get("preferences", "userCustomFallbackEnabled") and CommandSageDB.customFallbacks then
        for _, cb in ipairs(CommandSageDB.customFallbacks) do
            addCommand(cb, {
                callback = function(msg)
                    print("User fallback for " .. cb .. " with:", msg or "")
                end,
                source = "UserFallback",
                description = "User-added fallback"
            })
        end
    end
end

-- Scan built-in Blizzard commands by iterating over SlashCmdList.
local function ScanBuiltIn()
    for key, func in pairs(SlashCmdList) do
        local i = 1
        while true do
            local slash = _G["SLASH_" .. key .. i]
            if not slash then break end
            addCommand(slash, { callback = func, source = "Blizzard", description = "<No description>" })
            i = i + 1
        end
    end
end

-- Scan macros: global and character macros.
local function ScanMacros()
    local global, char = GetNumMacros()
    for i = 1, global do
        local name, icon, body = GetMacroInfo(i)
        if name then
            addCommand("/" .. name, {
                callback = function(msg)
                    print("Macro: ", name, "body:", body)
                end,
                source = "Macro",
                description = "Macro: " .. name
            })
        end
    end
    for i = 1, char do
        local name, icon, body = GetMacroInfo(global + i)
        if name then
            addCommand("/" .. name, {
                callback = function(msg)
                    print("Character macro: ", name, "body:", body)
                end,
                source = "Macro",
                description = "Char Macro: " .. name
            })
        end
    end
end

-- Scan Ace (or similar library) registered commands.
local function ScanAce()
    if not CommandSage_Config.Get("preferences", "macroInclusion") then
        return
    end
    -- Here we simply reuse the macro scan; if an Ace registry is available, extend here.
    ScanMacros()
end

-- Scan for emote commands. In addition to a hardcoded list, try to use a global EMOTE_LIST if available.
local function ScanEmotes()
    local hardcodedEmotes = { "/dance", "/cheer", "/wave", "/laugh", "/cry", "/roar", "/salute", "/smile", "/frown" }
    for _, e in ipairs(hardcodedEmotes) do
        addCommand(e, { callback = function(msg) print("Emote executed: " .. e) end, source = "Emote", description = "Emote " .. e })
    end
    if _G.EMOTE_LIST and type(_G.EMOTE_LIST) == "table" then
        for _, e in ipairs(_G.EMOTE_LIST) do
            if type(e) == "string" then
                addCommand(e, { callback = function(msg) print("Emote executed (global): " .. e) end, source = "Emote", description = "Emote " .. e })
            end
        end
    end
end

-- Scan for help commands. Look for a primary help command plus any command key that contains "help".
local function ScanHelp()
    if SlashCmdList["HELP"] then
        local helpSlash = _G["SLASH_HELP1"]
        if helpSlash then
            addCommand(helpSlash, { callback = SlashCmdList["HELP"], source = "Help", description = "Built-in help command" })
        end
    end
    for key, func in pairs(SlashCmdList) do
        if key:lower():find("help") and _G["SLASH_" .. key .. "1"] then
            local slash = _G["SLASH_" .. key .. "1"]
            addCommand(slash, { callback = func, source = "Help", description = "Help command: " .. key })
        end
    end
end

-- Scan extra commands defined in our extraCommands table.
local function ScanExtra()
    for _, cmd in ipairs(extraCommands) do
        addCommand(cmd.slash, { callback = cmd.callback, source = cmd.source, description = cmd.description })
    end
end

-- Scan the global environment for any variables starting with "SLASH_"
-- that might not have been captured already.
local function ScanGlobalSlashCommands()
    for k, v in pairs(_G) do
        if type(k) == "string" and k:sub(1,6) == "SLASH_" and type(v) == "string" then
            local lower = v:lower()
            if not discoveredCommands[lower] then
                -- Try to get the corresponding callback from SlashCmdList.
                local key = k:match("SLASH_(%w+)%d+")
                local func = SlashCmdList[key]
                if func then
                    addCommand(v, { callback = func, source = "GlobalScan", description = "Discovered via global scan" })
                end
            end
        end
    end
end

-- Scan AceConsole commands if available and enabled.
local function ScanAceConsole()
    if not CommandSage_Config.Get("preferences", "aceConsoleInclusion") then
        return
    end
    local AceConsole = LibStub and LibStub("AceConsole-3.0", true)
    if AceConsole and AceConsole.GetCommands then
        local cmds = AceConsole:GetCommands()  -- Assume GetCommands returns a table: command -> callback
        if cmds and type(cmds) == "table" then
            for cmd, func in pairs(cmds) do
                addCommand(cmd, { callback = func, source = "AceConsole", description = "AceConsole command: " .. cmd })
            end
        end
    end
end

-- Scan for custom commands from a global table.
local function ScanCustomCommands()
    if _G.CustomSlashCommands and type(_G.CustomSlashCommands) == "table" then
        for slash, data in pairs(_G.CustomSlashCommands) do
            addCommand(slash, { callback = data.callback, source = data.source or "Custom", description = data.description })
        end
    end
end

-- Main scan function: clear discoveredCommands, then call all scans.
function CommandSage_Discovery:ScanAllCommands()
    wipe(discoveredCommands)
    if CommandSage_Config.Get("preferences", "blizzAllFallback") then
        ScanBuiltIn()
    end
    ScanMacros()
    ScanAce()
    ScanEmotes()
    ScanHelp()
    ScanExtra()
    ScanGlobalSlashCommands()
    ScanAceConsole()
    ScanCustomCommands()
    ForceFallbacks()

    -- Insert all discovered commands into the Trie.
    for slash, data in pairs(discoveredCommands) do
        CommandSage_Trie:InsertCommand(slash, data)
    end

    CommandSage_DeveloperAPI:FireEvent("COMMANDS_UPDATED")
end

function CommandSage_Discovery:GetDiscoveredCommands()
    return discoveredCommands
end

function CommandSage_Discovery:ForceAllFallbacks(newFallbacks)
    if type(newFallbacks) == "table" then
        for _, slash in ipairs(newFallbacks) do
            table.insert(forcedFallback, slash)
        end
        print("CommandSage: Additional fallback commands added.")
    end
end
