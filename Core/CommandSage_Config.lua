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
            contextAwareness         = true,   -- e.g. in-combat vs not
            voiceCommandEnabled      = false,
            fallbackEnabled          = false,
            autoTypeDelay            = 0.03,
            persistHistory           = true,
            snippetEnabled           = true,
            contextFiltering         = true,
            typeAheadPrediction      = true,
            suggestionMode           = "fuzzy",  -- or "strict"

            -- Preferences from previous updates:
            overrideHotkeysWhileTyping = true,
            favoritesSortingEnabled    = true,

            -- New config options from last release:
            autocompleteOpenDirection      = "down", -- "up" or "down"
            maxSuggestionsOverride         = nil,
            showParamSuggestionsInColor    = true,
            paramSuggestionsColor          = { 1.0, 0.8, 0.0 }, -- gold
            showDescriptionsInAutocomplete = true,
            terminalNavigationEnabled      = true,  -- up/down/tab in shell style
            advancedStyling               = true,
            enableTerminalGoodies          = true,

            -- =====================================
            -- NEW Preferences (Enhancements)
            -- =====================================
            advancedKeybinds         = true,   -- Shift+Up/Down, Ctrl+C, etc.
            partialFuzzyFallback     = true,   -- fallback to searching entire list if prefix fails
            shellContextEnabled      = false,  -- if true, allows '/cd' shell navigation
            monetizationEnabled      = false,  -- if you want to gate "pro" features
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
