-- =============================================================================
-- CommandSage_Discovery.lua
-- Dynamic scanning, forced fallback, macro integration
-- =============================================================================

CommandSage_Discovery = {}

local discoveredCommands = {}
local forcedFallback = {
    "/cmdsage", "/cmdsagehistory", "/help", "/?", "/reload", "/console",
    "/dance", "/macro", "/ghelp", "/yell", "/say", "/emote", "/combatlog", "/afk", "/dnd",
    "/camp", "/logout", "/played", "/time", "/script"
}

local function ForceFallbacks()
    for _, slash in ipairs(forcedFallback) do
        local lower = slash:lower()
        if not discoveredCommands[lower] then
            discoveredCommands[lower] = {
                slash       = lower,
                callback    = function(msg)
                    print("Fallback for " .. slash .. " with args:", msg or "")
                end,
                source      = "Fallback",
                description = "Auto-injected fallback command",
            }
        end
    end

    if CommandSage_Config.Get("preferences", "userCustomFallbackEnabled") then
        if CommandSageDB.customFallbacks then
            for _, cb in ipairs(CommandSageDB.customFallbacks) do
                local cbLower = cb:lower()
                if not discoveredCommands[cbLower] then
                    discoveredCommands[cbLower] = {
                        slash = cbLower,
                        callback = function(msg)
                            print("User fallback for " .. cb .. " with:", msg or "")
                        end,
                        source = "UserFallback",
                        description = "User-added fallback"
                    }
                end
            end
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
            slash = slash:lower()
            discoveredCommands[slash] = {
                slash       = slash,
                callback    = func,
                source      = "Blizzard",
                description = "<No description>"
            }
            i = i + 1
        end
    end
end

local function ScanMacros()
    -- If you want to automatically incorporate macros or something custom
end

local function ScanAce()
    if not CommandSage_Config.Get("preferences", "macroInclusion") then
        return
    end
    local global, char = GetNumMacros()
    for i = 1, global do
        local name, icon, body = GetMacroInfo(i)
        if name then
            local slash = "/" .. name:lower()
            discoveredCommands[slash] = {
                slash       = slash,
                callback    = function(msg)
                    print("In-game macro: ", name, "body:", body)
                end,
                source      = "Macro",
                description = "Macro: " .. name
            }
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
    ForceFallbacks()

    for slash, data in pairs(discoveredCommands) do
        CommandSage_Trie:InsertCommand(slash, data)
    end
    CommandSage_DeveloperAPI:FireEvent("COMMANDS_UPDATED")
end

function CommandSage_Discovery:GetDiscoveredCommands()
    return discoveredCommands
end
