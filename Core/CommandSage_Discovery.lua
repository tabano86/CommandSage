CommandSage_Discovery = {}
local discoveredCommands = {}

-- Removed "/help" and "/?" from forcedFallback to honor "blizzAllFallback = false" tests
local forcedFallback = {
    "/cmdsage", "/cmdsagehistory", --"/help", "/?",
    "/reload", "/console", "/dance", "/macro", "/ghelp"
}

local extraCommands = {
    { slash = "/gold", source = "Extra", description = "Display gold" },
    { slash = "/ping", source = "Extra", description = "Display latency" },
    { slash = "/mem",  source = "Extra", description = "Display memory usage" }
}

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

local function ForceFallbacks()
    for _, slash in ipairs(forcedFallback) do
        local lower = slash:lower()
        if not discoveredCommands[lower] then
            addCommand(lower, {
                callback = function(msg) end,
                source = "Fallback",
                description = "Auto fallback"
            })
        end
    end
    if CommandSage_Config.Get("preferences", "userCustomFallbackEnabled") and CommandSageDB.customFallbacks then
        for _, cb in ipairs(CommandSageDB.customFallbacks) do
            addCommand(cb, {
                callback = function(msg) end,
                source = "UserFallback",
                description = "User fallback"
            })
        end
    end
end

local function ScanBuiltIn()
    for key, func in pairs(SlashCmdList) do
        local i = 1
        while true do
            local slash = _G["SLASH_" .. key .. i]
            if not slash then
                break
            end
            addCommand(slash, { callback = func, source = "Blizzard", description = "<No description>" })
            i = i + 1
        end
    end
end

local function ScanMacros()
    local global, char = GetNumMacros()
    local seen = {}
    for i = 1, global do
        local name, icon, body = GetMacroInfo(i)
        if name and not seen[name:lower()] then
            seen[name:lower()] = true
            addCommand("/" .. name, { callback = function(msg) end, source = "Macro", description = "Macro: " .. name })
        end
    end
    for i = 1, char do
        local name, icon, body = GetMacroInfo(global + i)
        if name and not seen[name:lower()] then
            seen[name:lower()] = true
            addCommand("/" .. name, { callback = function(msg) end, source = "Macro", description = "Char Macro: " .. name })
        end
    end
end

local function ScanAce()
    if not CommandSage_Config.Get("preferences", "macroInclusion") then
        return
    end
    if CommandSage_Config.Get("preferences", "aceConsoleInclusion") then
        local AceConsole = LibStub and LibStub("AceConsole-3.0", true)
        if AceConsole and AceConsole.GetCommands then
            local cmds = AceConsole:GetCommands()
            if cmds and type(cmds) == "table" then
                for cmd, func in pairs(cmds) do
                    addCommand(cmd, { callback = func, source = "AceConsole", description = "AceConsole command: " .. cmd })
                end
            end
        end
    end
    ScanMacros()
end

local function ScanEmotes()
    local hardcodedEmotes = { "/dance", "/cheer", "/wave" }
    for _, e in ipairs(hardcodedEmotes) do
        addCommand(e, { callback = function(msg) end, source = "Emote", description = "Emote " .. e })
    end
    if _G.EMOTE_LIST and type(_G.EMOTE_LIST) == "table" then
        for _, e in ipairs(_G.EMOTE_LIST) do
            if type(e) == "string" then
                addCommand(e, { callback = function(msg) end, source = "Emote", description = "Emote " .. e })
            end
        end
    end
end

local function ScanHelp()
    -- Omit help forcibly if we want to rely on the config
    if SlashCmdList["HELP"] then
        local helpSlash = _G["SLASH_HELP1"]
        if helpSlash then
            addCommand(helpSlash, { callback = SlashCmdList["HELP"], source = "Help", description = "Help command" })
        end
    end
    for key, func in pairs(SlashCmdList) do
        if key:lower():find("help") and _G["SLASH_" .. key .. "1"] then
            local slash = _G["SLASH_" .. key .. "1"]
            addCommand(slash, { callback = func, source = "Help", description = "Help command: " .. key })
        end
    end
end

local function ScanExtra()
    for _, cmd in ipairs(extraCommands) do
        addCommand(cmd.slash, { callback = cmd.callback, source = cmd.source, description = cmd.description })
    end
end

local function ScanGlobalSlashCommands()
    for k, v in pairs(_G) do
        if type(k) == "string" and k:sub(1, 6) == "SLASH_" and type(v) == "string" then
            local lower = v:lower()
            if not discoveredCommands[lower] then
                local key = k:match("SLASH_(%w+)%d+")
                local func = SlashCmdList[key]
                if func then
                    addCommand(v, { callback = func, source = "GlobalScan", description = "Discovered global slash" })
                end
            end
        end
    end
end

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
    ForceFallbacks()
    for slash, data in pairs(discoveredCommands) do
        CommandSage_Trie:InsertCommand(slash, data)
    end
    if CommandSage_DeveloperAPI and CommandSage_DeveloperAPI.FireEvent then
        CommandSage_DeveloperAPI:FireEvent("COMMANDS_UPDATED")
    end
end

function CommandSage_Discovery:GetDiscoveredCommands()
    return discoveredCommands
end

-- This ensures the fallback slash is recognized immediately:
function CommandSage_Discovery:ForceAllFallbacks(newFallbacks)
    if type(newFallbacks) == "table" then
        for _, slash in ipairs(newFallbacks) do
            table.insert(forcedFallback, slash)
        end
    end
    -- Re-run the fallback injection:
    ForceFallbacks()
end
