-- =============================================================================
-- CommandSage_CommandOrganizer.lua
-- Groups commands by category or custom tags for filtering
-- =============================================================================

CommandSage_CommandOrganizer = {}

local tagDB = {}

function CommandSage_CommandOrganizer:SetCommandTags(slash, tags)
    tagDB[slash] = tags
end

function CommandSage_CommandOrganizer:GetCommandTags(slash)
    return tagDB[slash] or {}
end

function CommandSage_CommandOrganizer:FilterCommandsByTag(tag)
    local results = {}
    for slash, discovered in pairs(CommandSage_Discovery:GetDiscoveredCommands()) do
        local cmdTags = tagDB[slash]
        if cmdTags then
            for _, t in ipairs(cmdTags) do
                if t == tag then
                    table.insert(results, slash)
                end
            end
        end
    end
    return results
end
