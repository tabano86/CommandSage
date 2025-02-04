-- =============================================================================
-- CommandSage_Analytics.lua
-- Favorites, blacklisting, usage stats
-- =============================================================================

CommandSage_Analytics = {}

local function EnsureAnalytics()
    if not CommandSageDB.analytics then
        CommandSageDB.analytics = {
            favorites = {},
            blacklisted = {},
            usageStats = {},
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
    return CommandSageDB.analytics.favorites[cmd]
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
    return CommandSageDB.analytics.blacklisted[cmd]
end
