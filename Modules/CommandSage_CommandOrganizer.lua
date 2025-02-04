-- =============================================================================
-- CommandSage_CommandOrganizer.lua
-- Group slash commands by category for potential filtering or display
-- =============================================================================

CommandSage_CommandOrganizer = {}

local tagDB = {
    ["/dance"]   = { "social" },
    ["/macro"]   = { "macros" },
    ["/cmdsage"] = { "plugin" },
    -- more known slash->category mappings if you like
}

function CommandSage_CommandOrganizer:GetCommandTags(slash)
    return tagDB[slash] or {}
end

function CommandSage_CommandOrganizer:GetCategory(slash)
    local t = self:GetCommandTags(slash)
    if #t > 0 then
        return t[1]
    end
    return "other"
end
