-- =============================================================================
-- CommandSage_Config.lua
-- Responsible for creating and loading default config into CommandSageDB
-- =============================================================================

CommandSage_Config = {}

function CommandSage_Config:InitializeDefaults()
    if not CommandSageDB then
        CommandSageDB = {}
    end
    if not CommandSageDB.config then
        CommandSageDB.config = {}
    end

    -- Basic user preferences, all ON by default
    if not CommandSageDB.config.preferences then
        CommandSageDB.config.preferences = {
            fuzzyMatchEnabled = true,
            fuzzyMatchTolerance = 2,
            maxSuggestions = 10,
            animateAutoType = true,
            showTutorialOnStartup = true,
            usageAnalytics = true,
            contextAwareness = true,
            voiceCommandEnabled = true,
            fallbackEnabled = false,      -- fallback OFF by default
            autoTypeDelay = 0.03,         -- faster auto-typing
            persistHistory = true,        -- new preference to remember commands
        }
    end
end

function CommandSage_Config.Get(category, key)
    if not CommandSageDB or not CommandSageDB.config then
        return nil
    end
    local catTable = CommandSageDB.config[category]
    if catTable then
        return catTable[key]
    end
    return nil
end

function CommandSage_Config.Set(category, key, value)
    if not CommandSageDB or not CommandSageDB.config then return end
    local catTable = CommandSageDB.config[category]
    if not catTable then
        catTable = {}
        CommandSageDB.config[category] = catTable
    end
    catTable[key] = value
end
