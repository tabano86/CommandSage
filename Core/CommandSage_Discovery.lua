-- =============================================================================
-- CommandSage_Discovery.lua
-- Dynamic scanning, background updates, forced fallback, macro integration
-- =============================================================================

CommandSage_Discovery = {}

local discoveredCommands = {}
local forcedFallback = {
    "/cmdsage", "/cmdsagehistory", "/help", "/?", "/reload", "/console",
    "/dance", "/macro", "/ghelp", "/yell", "/say", "/emote"
}

local function ForceFallbacks()
    for _, slash in ipairs(forcedFallback) do
        local lower = slash:lower()
        if not discoveredCommands[lower] then
            discoveredCommands[lower] = {
                slash = lower,
                callback = function(msg) print("Fallback for "..slash.." with args:", msg or "") end,
                source = "Fallback",
                description = "Auto-injected fallback command"
            }
        end
    end
end

-- Attempt to parse built-in slash commands
local function ScanBuiltIn()
    for key, func in pairs(SlashCmdList) do
        local i = 1
        while true do
            local slash = _G["SLASH_"..key..i]
            if not slash then break end
            slash = slash:lower()
            discoveredCommands[slash] = {
                slash = slash,
                callback = func,
                source = "Blizzard",
                description = "<No description>",
            }
            i = i + 1
        end
    end
end

local function ScanMacros()
    -- Stubs for reading macros
    -- local global, char = GetNumMacros()
    -- ...
end

local function ScanAce()
    -- If Ace is loaded, we can introspect AceConsole or similar
end

function CommandSage_Discovery:ScanAllCommands()
    wipe(discoveredCommands)
    ScanBuiltIn()
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

-- We'll do a background timer to re-scan every 3 minutes or so
local bgFrame = CreateFrame("Frame")
bgFrame.elapsed = 0
bgFrame:SetScript("OnUpdate", function(self, e)
    self.elapsed = self.elapsed + e
    if self.elapsed > 180 then
        self.elapsed = 0
        CommandSage_Discovery:ScanAllCommands()
        -- silent re-scan
    end
end)
