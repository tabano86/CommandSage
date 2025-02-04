-- =============================================================================
-- CommandSage_CommandOrganizer.lua
-- Group commands by category (combat, social, macros, etc.)
-- =============================================================================

CommandSage_CommandOrganizer = {}

local tagDB = {
    ["/dance"] = { "social" },
    ["/macro"] = { "macros" },
    ["/cmdsage"] = { "plugin" },
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
