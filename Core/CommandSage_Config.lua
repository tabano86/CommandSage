-- =============================================================================
-- CommandSage_Config.lua
-- All features ON by default, plus extra user config from new features
-- =============================================================================

CommandSage_Config = {}

function CommandSage_Config:InitializeDefaults()
    if not CommandSageDB then
        CommandSageDB = {}
    end

    if not CommandSageDB.config then
        CommandSageDB.config = {}
    end

    local prefs = CommandSageDB.config.preferences
    if not prefs then
        prefs = {
            -- Existing defaults:
            fuzzyMatchEnabled        = true,
            fuzzyMatchTolerance      = 2,
            maxSuggestions           = 12,
            animateAutoType          = true,
            showTutorialOnStartup    = true,
            usageAnalytics           = true,
            contextAwareness         = true,  -- e.g. in-combat vs not
            voiceCommandEnabled      = false,
            fallbackEnabled          = false,
            autoTypeDelay            = 0.03,
            persistHistory           = true,
            snippetEnabled           = true,
            contextFiltering         = true,
            typeAheadPrediction      = true,
            suggestionMode           = "fuzzy",  -- or "strict"

            -- Preferences added in a previous update:
            overrideHotkeysWhileTyping = true,
            favoritesSortingEnabled    = true,

            -- NEW: Additional user config options
            autocompleteOpenDirection      = "down",  -- "up" or "down"
            maxSuggestionsOverride         = nil,      -- user can override the default
            showParamSuggestionsInColor    = true,
            paramSuggestionsColor          = { 1.0, 0.8, 0.0 }, -- a golden color
            showDescriptionsInAutocomplete = true,
            terminalNavigationEnabled      = true, -- up/down/tab mimics typical shell
            advancedStyling               = true,  -- "prettier" UI if true
            enableTerminalGoodies          = true,  -- e.g. /cls, /lsmacros, etc.
        }
        CommandSageDB.config.preferences = prefs
    end
end

function CommandSage_Config.Get(category, key)
    if not CommandSageDB or not CommandSageDB.config then
        return nil
    end
    local cTable = CommandSageDB.config[category]
    if cTable then
        return cTable[key]
    end
    return nil
end

function CommandSage_Config.Set(category, key, value)
    if not CommandSageDB or not CommandSageDB.config then
        return
    end
    local cTable = CommandSageDB.config[category]
    if not cTable then
        cTable = {}
        CommandSageDB.config[category] = cTable
    end
    cTable[key] = value
end
