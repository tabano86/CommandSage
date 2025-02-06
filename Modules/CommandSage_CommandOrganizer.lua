CommandSage_CommandOrganizer = {}
local tagDB = {
    ["/dance"] = { "social" },
    ["/macro"] = { "macros" },
    ["/cmdsage"] = { "plugin" }
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
function CommandSage_CommandOrganizer:GetAllCategories()
    local catSet = {}
    for slash, tags in pairs(tagDB) do
        for _, tag in ipairs(tags) do
            catSet[tag] = true
        end
    end
    local out = {}
    for tag in pairs(catSet) do
        table.insert(out, tag)
    end
    return out
end
