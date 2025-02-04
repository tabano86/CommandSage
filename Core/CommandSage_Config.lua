-- =============================================================================
-- CommandSage_Config.lua
-- Holds addon-wide configuration defaults and getters/setters.
-- Includes DB versioning for simple migration if needed.
-- =============================================================================

CommandSage_Config = {}

local CURRENT_DB_VERSION = 4  -- Bumped from 3 to 4 for new preference migration

function CommandSage_Config:InitializeDefaults()
    if not CommandSageDB then
        CommandSageDB = {}
    end

    -- DB versioning
    if not CommandSageDB.dbVersion or CommandSageDB.dbVersion < CURRENT_DB_VERSION then
        CommandSageDB.dbVersion = CURRENT_DB_VERSION
        -- Place migration logic here if needed
    end

    if not CommandSageDB.config then
        CommandSageDB.config = {}
    end

    local prefs = CommandSageDB.config.preferences
    if not prefs then
        prefs = {
            -- Existing (older) defaults:
            fuzzyMatchEnabled          = true,
            fuzzyMatchTolerance        = 2,
            maxSuggestions             = 12,
            animateAutoType            = true,
            showTutorialOnStartup      = true,
            usageAnalytics             = true,
            contextAwareness           = true,
            voiceCommandEnabled        = false,
            fallbackEnabled            = false,
            autoTypeDelay              = 0.03,
            persistHistory             = true,
            snippetEnabled             = true,
            contextFiltering           = true,
            typeAheadPrediction        = true,
            suggestionMode             = "fuzzy",
            overrideHotkeysWhileTyping = true,
            favoritesSortingEnabled    = true,
            autocompleteOpenDirection  = "down",
            maxSuggestionsOverride     = nil,
            showParamSuggestionsInColor= true,
            paramSuggestionsColor      = { 1.0, 0.8, 0.0 },
            showDescriptionsInAutocomplete = true,
            terminalNavigationEnabled  = true,
            advancedStyling            = true,
            enableTerminalGoodies       = true,
            advancedKeybinds            = true,
            partialFuzzyFallback        = true,
            shellContextEnabled         = false,
            monetizationEnabled         = false,

            -- Newer expansions:
            uiTheme                    = "dark",
            uiScale                    = 1.0,
            autocompleteBgColor        = { 0, 0, 0, 0.85 },
            autocompleteHighlightColor = { 0.6, 0.6, 0.6, 0.3 },
            tutorialFadeIn             = true,
            configGuiEnabled           = true,

            -- NEW in version 4.1: fully disable hotkeys in chat
            alwaysDisableHotkeysInChat = false,
        }
        CommandSageDB.config.preferences = prefs
    end

    -- Ensure newly introduced keys exist
    if prefs.uiTheme == nil then
        prefs.uiTheme = "dark"
    end
    if prefs.uiScale == nil then
        prefs.uiScale = 1.0
    end
    if prefs.autocompleteBgColor == nil then
        prefs.autocompleteBgColor = {0, 0, 0, 0.85}
    end
    if prefs.autocompleteHighlightColor == nil then
        prefs.autocompleteHighlightColor = {0.6, 0.6, 0.6, 0.3}
    end
    if prefs.tutorialFadeIn == nil then
        prefs.tutorialFadeIn = true
    end
    if prefs.configGuiEnabled == nil then
        prefs.configGuiEnabled = true
    end
    -- Check our newly added key
    if prefs.alwaysDisableHotkeysInChat == nil then
        prefs.alwaysDisableHotkeysInChat = false
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

-- Enhancement: A quick helper to "reset" all preferences (in case user wants defaults)
function CommandSage_Config:ResetPreferences()
    CommandSageDB.config.preferences = nil
    self:InitializeDefaults()
    print("CommandSage: Preferences reset to default.")
end
