-- =============================================================================
-- CommandSage_Discovery.lua
-- Scans for slash commands (both built-in and addon-defined) and updates the Trie
-- =============================================================================

CommandSage_Discovery = {}

local discoveredCommands = {}

local forcedFallback = {
    "/cmdsage", "/cmdsagehistory", "/help", "/?", "/reload", "/console",
    "/dance", "/ghelp", "/macro" -- add more if you like
}

local function ForceSomeCommands()
    for _, scmd in ipairs(forcedFallback) do
        local lower = scmd:lower()
        if not discoveredCommands[lower] then
            discoveredCommands[lower] = {
                slash = lower,
                callback = function(msg)
                    print("Fallback for "..scmd.." with args: "..(msg or ""))
                end,
                source = "Fallback",
                description = "Autoinjected command"
            }
        end
    end
end

local function ScanBuiltInSlashCommands()
    for key, func in pairs(SlashCmdList) do
        local i = 1
        while true do
            local slash = _G["SLASH_"..key..i]
            if not slash then break end
            local lower = slash:lower()
            discoveredCommands[lower] = {
                slash = lower,
                callback = func,
                source = "Blizzard",
                description = "<No Description>",
            }
            i = i + 1
        end
    end
end

-- Stub to read macros, if you want
local function ScanMacros()
    -- If we rely on in-game macros, we do:
    -- local global, char = GetNumMacros()
    -- for i=1, global do
    --     local name, icon, body = GetMacroInfo(i)
    --     discoveredCommands["/"..name:lower()] = ...
end

local function ScanAceCommands()
    -- Hook into AceConsole, etc. if present
end

function CommandSage_Discovery:ScanAllCommands()
    wipe(discoveredCommands)
    ScanBuiltInSlashCommands()
    ScanMacros()
    ScanAceCommands()
    ForceSomeCommands()

    for slash, data in pairs(discoveredCommands) do
        CommandSage_Trie:InsertCommand(slash, data)
    end
    CommandSage_DeveloperAPI:FireEvent("COMMANDS_UPDATED")
end

function CommandSage_Discovery:GetDiscoveredCommands()
    return discoveredCommands
end
