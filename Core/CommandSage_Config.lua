-- =============================================================================
-- CommandSage_Config.lua
-- Core config with DB versioning + new visual feature toggles
-- =============================================================================

CommandSage_Config = {}

local CURRENT_DB_VERSION = 5  -- Bumped to 5 to incorporate new toggles

function CommandSage_Config:InitializeDefaults()
    if not CommandSageDB then
        CommandSageDB = {}
    end

    -- DB versioning
    if not CommandSageDB.dbVersion or CommandSageDB.dbVersion < CURRENT_DB_VERSION then
        CommandSageDB.dbVersion = CURRENT_DB_VERSION
    end

    if not CommandSageDB.config then
        CommandSageDB.config = {}
    end

    local prefs = CommandSageDB.config.preferences
    if not prefs then
        prefs = {
            -- Existing
            fuzzyMatchEnabled             = true,
            fuzzyMatchTolerance           = 2,
            maxSuggestions                = 12,
            animateAutoType               = true,
            showTutorialOnStartup         = true,
            usageAnalytics                = true,
            contextAwareness              = true,
            voiceCommandEnabled           = false,
            fallbackEnabled               = false,
            autoTypeDelay                 = 0.08,
            persistHistory                = true,
            snippetEnabled                = true,
            contextFiltering              = true,
            typeAheadPrediction           = true,
            suggestionMode                = "fuzzy",
            overrideHotkeysWhileTyping    = true,
            favoritesSortingEnabled       = true,
            autocompleteOpenDirection     = "down",
            maxSuggestionsOverride        = nil,
            showParamSuggestionsInColor   = true,
            paramSuggestionsColor         = { 1.0, 0.8, 0.0 },
            showDescriptionsInAutocomplete= true,
            terminalNavigationEnabled     = true,
            advancedStyling               = true,
            enableTerminalGoodies         = true,
            advancedKeybinds              = true,
            partialFuzzyFallback          = true,
            shellContextEnabled           = true,
            monetizationEnabled           = false,
            macroInclusion                = true,
            aceConsoleInclusion           = true,
            blizzAllFallback              = true,
            userCustomFallbackEnabled     = false,
            uiTheme                       = "dark",
            uiScale                       = 1.0,
            autocompleteBgColor           = { 0, 0, 0, 0.85 },
            autocompleteHighlightColor    = { 0.6, 0.6, 0.6, 0.3 },
            tutorialFadeIn                = true,
            configGuiEnabled              = true,
            alwaysDisableHotkeysInChat    = true,

            -- NEW toggles for 10 visually distinctive features:
            rainbowBorderEnabled          = false,
            spinningIconEnabled           = false,
            emoteStickersEnabled          = false,
            usageChartEnabled             = false,
            paramGlowEnabled              = false,
            chatInputHaloEnabled          = false,
            colorCommandEnabled           = false,
            spin3DEnabled                 = false,
            arRuneRingEnabled             = false,
            advancedEmoteEffectsEnabled   = false,
        }
        CommandSageDB.config.preferences = prefs
    end

    -- Ensure every new key is present
    if prefs.rainbowBorderEnabled == nil then
        prefs.rainbowBorderEnabled = false
    end
    if prefs.spinningIconEnabled == nil then
        prefs.spinningIconEnabled = false
    end
    if prefs.emoteStickersEnabled == nil then
        prefs.emoteStickersEnabled = false
    end
    if prefs.usageChartEnabled == nil then
        prefs.usageChartEnabled = false
    end
    if prefs.paramGlowEnabled == nil then
        prefs.paramGlowEnabled = false
    end
    if prefs.chatInputHaloEnabled == nil then
        prefs.chatInputHaloEnabled = false
    end
    if prefs.colorCommandEnabled == nil then
        prefs.colorCommandEnabled = false
    end
    if prefs.spin3DEnabled == nil then
        prefs.spin3DEnabled = false
    end
    if prefs.arRuneRingEnabled == nil then
        prefs.arRuneRingEnabled = false
    end
    if prefs.advancedEmoteEffectsEnabled == nil then
        prefs.advancedEmoteEffectsEnabled = false
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

function CommandSage_Config:ResetPreferences()
    CommandSageDB.config.preferences = nil
    self:InitializeDefaults()
    print("CommandSage: Preferences reset to default.")
end
