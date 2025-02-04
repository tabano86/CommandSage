-- =============================================================================
-- CommandSage_Discovery.lua
-- Scans for slash commands (both built-in and addon-defined) and updates the Trie
-- =============================================================================

CommandSage_Discovery = {}

local discoveredCommands = {}

-- Attempts to discover built-in slash commands (we can read _G.SlashCmdList keys)
local function ScanBuiltInSlashCommands()
    for key, func in pairs(SlashCmdList) do
        -- The actual slash name is discovered by scanning _G["SLASH_"..key.."1"], etc.
        local i = 1
        while true do
            local slash = _G["SLASH_"..key..i]
            if not slash then break end
            discoveredCommands[slash:lower()] = {
                slash = slash:lower(),
                callback = func,
                source = "Blizzard",
                description = "<No Description>", -- Could attempt to parse help text
            }
            i = i + 1
        end
    end
end

-- (Stub) Possibly detect macros by reading global macros if WoW's API allowed enumerating them
-- WoW does have GetNumMacros / GetMacroInfo for in-game macros, but not reading WTF files directly.
local function ScanMacros()
    -- Placeholder: We can do something like:
    -- local global, char = GetNumMacros()
    -- for i=1, global do
    --     local name, icon, body = GetMacroInfo(i)
    --     ...
    -- end
    -- For now, we just stub:
end

-- (Stub) Possibly hooking Ace or other libraries
local function ScanAceCommands()
    -- This would require hooking into AceConsole-3.0 or similar if present.
    -- For demonstration, we just stub:
end

function CommandSage_Discovery:ScanAllCommands()
    wipe(discoveredCommands)
    ScanBuiltInSlashCommands()
    ScanMacros()
    ScanAceCommands()

    -- Insert discovered commands into our Trie
    for slash, data in pairs(discoveredCommands) do
        CommandSage_Trie:InsertCommand(slash, data)
    end

    -- Fire an event or signal that commands were updated
    CommandSage_DeveloperAPI:FireEvent("COMMANDS_UPDATED")
end

function CommandSage_Discovery:GetDiscoveredCommands()
    return discoveredCommands
end
