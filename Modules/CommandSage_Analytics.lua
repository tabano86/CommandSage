CommandSage_Analytics = {}
local function EnsureAnalytics()
    if type(CommandSageDB) ~= "table" then
        CommandSageDB = {}
    end
    if type(CommandSageDB.analytics) ~= "table" then
        CommandSageDB.analytics = {
            favorites = {},
            blacklisted = {},
            usageStats = {}
        }
    end
end
function CommandSage_Analytics:AddFavorite(cmd)
    EnsureAnalytics()
    CommandSageDB.analytics.favorites[cmd] = true
end
function CommandSage_Analytics:RemoveFavorite(cmd)
    EnsureAnalytics()
    CommandSageDB.analytics.favorites[cmd] = nil
end
function CommandSage_Analytics:IsFavorite(cmd)
    EnsureAnalytics()
    return CommandSageDB.analytics.favorites[cmd] or false
end
function CommandSage_Analytics:Blacklist(cmd)
    EnsureAnalytics()
    CommandSageDB.analytics.blacklisted[cmd] = true
end
function CommandSage_Analytics:Unblacklist(cmd)
    EnsureAnalytics()
    CommandSageDB.analytics.blacklisted[cmd] = nil
end
function CommandSage_Analytics:IsBlacklisted(cmd)
    EnsureAnalytics()
    return CommandSageDB.analytics.blacklisted[cmd] or false
end
function CommandSage_Analytics:ListFavorites()
    EnsureAnalytics()
    local favs = {}
    for c, _ in pairs(CommandSageDB.analytics.favorites) do
        table.insert(favs, c)
    end
    return favs
end

return CommandSage_Analytics
