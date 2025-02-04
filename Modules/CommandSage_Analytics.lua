-- =============================================================================
-- CommandSage_Analytics.lua
-- Gathers anonymized usage data, user feedback (favorite / blacklist) stubs
-- =============================================================================

CommandSage_Analytics = {}

local function EnsureAnalyticsDB()
    if not CommandSageDB.analytics then
        CommandSageDB.analytics = {
            favorites = {},
            blacklisted = {},
            usageStats = {},
        }
    end
end

function CommandSage_Analytics:AddFavorite(cmd)
    EnsureAnalyticsDB()
    CommandSageDB.analytics.favorites[cmd] = true
end

function CommandSage_Analytics:RemoveFavorite(cmd)
    EnsureAnalyticsDB()
    CommandSageDB.analytics.favorites[cmd] = nil
end

function CommandSage_Analytics:IsFavorite(cmd)
    EnsureAnalyticsDB()
    return CommandSageDB.analytics.favorites[cmd]
end

function CommandSage_Analytics:Blacklist(cmd)
    EnsureAnalyticsDB()
    CommandSageDB.analytics.blacklisted[cmd] = true
end

function CommandSage_Analytics:Unblacklist(cmd)
    EnsureAnalyticsDB()
    CommandSageDB.analytics.blacklisted[cmd] = nil
end

function CommandSage_Analytics:IsBlacklisted(cmd)
    EnsureAnalyticsDB()
    return CommandSageDB.analytics.blacklisted[cmd]
end
