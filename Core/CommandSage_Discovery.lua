-- File: Core/CommandSage_Discovery.lua
-- Enhanced discovery module that scans for slash commands from multiple sources:
--   - Built-in slash commands (via SlashCmdList and global SLASH_ keys)
--   - Macros (global and character)
--   - AceConsole commands (if enabled)
--   - Emotes and hard-coded commands
--   - Extra commands (e.g. /gold, /ping, /mem)
--   - Custom commands from CommandSageDB.customCommands
--   - Adaptive usage data from CommandSageDB.usageData
--   - Known parameters from CommandSage_ParameterHelper
-- Additionally, we now also scan for *help* commands from any addon by iterating over
-- all globals whose keys begin with "SLASH_" and checking if the key or value contains
-- "help" (case–insensitive).
--
-- After scanning, each normalized command is inserted into CommandSage_Trie,
-- and a "COMMANDS_UPDATED" event is fired.

CommandSage_Discovery = {}
local discoveredCommands = {}  -- keys: normalized slash; values: command info

-- CONFIGURATION: forced fallback and extra commands
local forcedFallback = {
    "/cmdsage", "/cmdsagehistory", -- help commands purposely removed from auto-suggestions
    "/reload", "/console", "/dance", "/macro", "/ghelp"
}

local extraCommands = {
    { slash = "/gold", source = "Extra", description = "Display gold" },
    { slash = "/ping", source = "Extra", description = "Display latency" },
    { slash = "/mem", source = "Extra", description = "Display memory usage" }
}

--------------------------------------------------------------------------------
-- Utility Functions
--------------------------------------------------------------------------------
local function normalizeSlash(slash)
    if type(slash) ~= "string" then return nil end
    local trimmed = slash:match("^%s*(.-)%s*$")
    if trimmed == "" then return nil end
    if trimmed:sub(1,1) ~= "/" then trimmed = "/" .. trimmed end
    return trimmed:lower()
end

local function addCommand(slash, data)
    local norm = normalizeSlash(slash)
    if not norm then return end
    if not discoveredCommands[norm] then
        discoveredCommands[norm] = {
            slash = norm,
            callback = (type(data.callback) == "function") and data.callback or function(msg) end,
            source = data.source or "Unknown",
            description = data.description or "<No description>",
            params = data.params  -- optional field
        }
    else
        local curr = discoveredCommands[norm]
        if data.description and not curr.description:find(data.description, 1, true) then
            curr.description = curr.description .. " | " .. data.description
        end
    end
end

local function debugLog(msg)
    if CommandSage and CommandSage.debugMode then
        print("|cff999999[CommandSage-Discovery Debug]|r", msg)
    end
end

--------------------------------------------------------------------------------
-- Scanning Functions (each wrapped in pcall to isolate errors)
--------------------------------------------------------------------------------
local function ScanBuiltIn()
    if not SlashCmdList then return end
    for key, func in pairs(SlashCmdList) do
        if type(func) == "function" then
            local i = 1
            while true do
                local varName = "SLASH_" .. key .. i
                local slash = _G[varName]
                if not slash then break end
                if type(slash) == "string" then
                    addCommand(slash, { callback = func, source = "Blizzard", description = "<No description>" })
                end
                i = i + 1
            end
        end
    end
end

local function ScanMacros()
    if not (GetNumMacros and GetMacroInfo) then return end
    local global, char = GetNumMacros()
    local seen = {}
    for i = 1, global do
        local name, icon, body = GetMacroInfo(i)
        if name and type(name) == "string" and not seen[name:lower()] then
            seen[name:lower()] = true
            addCommand("/" .. name, { callback = function(msg) end, source = "Macro", description = "Macro: " .. name })
        end
    end
    for i = 1, char do
        local name, icon, body = GetMacroInfo(global + i)
        if name and type(name) == "string" and not seen[name:lower()] then
            seen[name:lower()] = true
            addCommand("/" .. name, { callback = function(msg) end, source = "Macro", description = "Char Macro: " .. name })
        end
    end
end

local function ScanAce()
    if not CommandSage_Config.Get("preferences", "macroInclusion") then return end
    if CommandSage_Config.Get("preferences", "aceConsoleInclusion") then
        local AceConsole = LibStub and LibStub("AceConsole-3.0", true)
        if AceConsole and type(AceConsole.GetCommands) == "function" then
            local cmds = AceConsole:GetCommands()
            if cmds and type(cmds) == "table" then
                for cmd, func in pairs(cmds) do
                    if type(cmd) == "string" then
                        addCommand(cmd, { callback = func, source = "AceConsole", description = "AceConsole command: " .. cmd })
                    end
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
    if SlashCmdList and SlashCmdList["HELP"] then
        local helpSlash = _G["SLASH_HELP1"]
        if helpSlash and type(helpSlash) == "string" then
            addCommand(helpSlash, { callback = SlashCmdList["HELP"], source = "Help", description = "Help command" })
        end
    end
    if SlashCmdList then
        for key, func in pairs(SlashCmdList) do
            if type(key) == "string" and key:lower():find("help") then
                local varName = "SLASH_" .. key .. "1"
                local slash = _G[varName]
                if slash and type(slash) == "string" then
                    addCommand(slash, { callback = func, source = "Help", description = "Help command: " .. key })
                end
            end
        end
    end
end

local function ScanGlobalSlashCommands()
    for k, v in pairs(_G) do
        if type(k) == "string" and k:sub(1, 6) == "SLASH_" and type(v) == "string" then
            local norm = normalizeSlash(v)
            if norm and not discoveredCommands[norm] then
                local key = k:match("SLASH_(%w+)%d+")
                if key and SlashCmdList and type(SlashCmdList[key]) == "function" then
                    addCommand(v, { callback = SlashCmdList[key], source = "GlobalScan", description = "Discovered global slash" })
                end
            end
        end
    end
end

local function ScanAddonHelp()
    for k, v in pairs(_G) do
        if type(k) == "string" and k:sub(1, 6) == "SLASH_" and type(v) == "string" then
            if k:lower():find("help") or v:lower():find("help") then
                local norm = normalizeSlash(v)
                if norm and not discoveredCommands[norm] then
                    local key = k:match("SLASH_(%w+)%d+")
                    local callback = (SlashCmdList and SlashCmdList[key]) or function() end
                    addCommand(v, { callback = callback, source = "AddonHelp", description = "Addon help command (" .. key .. ")" })
                    debugLog("Scanned addon help command: " .. norm)
                end
            end
        end
    end
end

local function ScanExtra()
    for _, cmd in ipairs(extraCommands) do
        if cmd and type(cmd.slash) == "string" then
            addCommand(cmd.slash, { callback = cmd.callback, source = cmd.source, description = cmd.description })
        end
    end
end

local function ScanCustomCommands()
    if CommandSageDB and type(CommandSageDB.customCommands) == "table" then
        for _, cmd in ipairs(CommandSageDB.customCommands) do
            if type(cmd) == "table" and cmd.slash then
                addCommand(cmd.slash, {
                    callback = cmd.callback or function(msg) end,
                    source = "UserCustom",
                    description = cmd.description or "<No description>"
                })
            end
        end
    end
end

local function ScanAdaptiveUsage()
    if CommandSageDB and type(CommandSageDB.usageData) == "table" then
        for slash, usage in pairs(CommandSageDB.usageData) do
            local norm = normalizeSlash(slash)
            if norm and not discoveredCommands[norm] then
                addCommand(norm, {
                    callback = function(msg) end,
                    source = "AdaptiveUsage",
                    description = "Used " .. usage .. " time(s)"
                })
            end
        end
    end
end

local function ScanKnownParams()
    if CommandSage_ParameterHelper and type(CommandSage_ParameterHelper.ExposeKnownParams) == "function" then
        local kp = CommandSage_ParameterHelper:ExposeKnownParams()
        for slash, params in pairs(kp) do
            local norm = normalizeSlash(slash)
            if norm then
                if discoveredCommands[norm] then
                    local curr = discoveredCommands[norm].description
                    discoveredCommands[norm].description = curr .. " | Known params: " .. table.concat(params, ", ")
                else
                    addCommand(norm, {
                        callback = function(msg) end,
                        source = "ParameterHelper",
                        description = "Known parameters: " .. table.concat(params, ", ")
                    })
                end
            end
        end
    end
end

local function ForceFallbacks()
    for _, slash in ipairs(forcedFallback) do
        local norm = normalizeSlash(slash)
        if norm and not discoveredCommands[norm] then
            addCommand(norm, {
                callback = function(msg) end,
                source = "Fallback",
                description = "Auto fallback"
            })
        end
    end
    if CommandSage_Config.Get("preferences", "userCustomFallbackEnabled") and CommandSageDB and CommandSageDB.customFallbacks then
        for _, cb in ipairs(CommandSageDB.customFallbacks) do
            if type(cb) == "string" then
                addCommand(cb, {
                    callback = function(msg) end,
                    source = "UserFallback",
                    description = "User fallback"
                })
            end
        end
    end
end

--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------
function CommandSage_Discovery:ScanAllCommands()
    -- Clear the previously discovered commands.
    if wipe then
        wipe(discoveredCommands)
    else
        for k in pairs(discoveredCommands) do
            discoveredCommands[k] = nil
        end
    end

    local scanners = {
        ScanBuiltIn,
        ScanMacros,
        ScanAce,
        ScanEmotes,
        ScanHelp,
        ScanAddonHelp,
        ScanGlobalSlashCommands,
        ScanExtra,
        ScanCustomCommands,
        ScanAdaptiveUsage,
        ScanKnownParams,
        ForceFallbacks
    }

    for _, scanner in ipairs(scanners) do
        local ok, err = pcall(scanner)
        if not ok then
            debugLog("Error in scanner: " .. tostring(err))
        end
    end

    -- Insert each discovered command into the trie.
    if CommandSage_Trie and type(CommandSage_Trie.InsertCommand) == "function" then
        for slash, data in pairs(discoveredCommands) do
            local ok, err = pcall(function()
                CommandSage_Trie:InsertCommand(slash, data)
            end)
            if not ok then
                print("[CommandSage-Discovery Debug] Error inserting", slash, ":", err)
            end
        end
    end

    -- Fire an event to let other modules know the command list is updated.
    if CommandSage_DeveloperAPI and type(CommandSage_DeveloperAPI.FireEvent) == "function" then
        CommandSage_DeveloperAPI:FireEvent("COMMANDS_UPDATED")
    end

    -- Calculate total count without using the length operator on a number.
    local count = 0
    for _ in pairs(discoveredCommands) do
        count = count + 1
    end
    debugLog("ScanAllCommands completed. Total commands discovered: " .. tostring(count))
end

function CommandSage_Discovery:GetDiscoveredCommands()
    return discoveredCommands
end

function CommandSage_Discovery:ForceAllFallbacks(newFallbacks)
    if type(newFallbacks) == "table" then
        for _, slash in ipairs(newFallbacks) do
            table.insert(forcedFallback, slash)
        end
    end
    ForceFallbacks()
end

return CommandSage_Discovery
