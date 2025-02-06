-- File: Core/CommandSage_Config.lua
local CommandSage_Config = {}
local CURRENT_DB_VERSION = 1

-- Initializes default configuration values.
function CommandSage_Config:InitializeDefaults()
    if not CommandSageDB then
        CommandSageDB = {
            preferences = {
                animateAutoType = true, -- Enable incremental typing by default
                autoTypeDelay = 0.1,
                suggestionMode = "fuzzy",
                fuzzyMatchEnabled = true,
                uiTheme = "dark",
                enableTerminalGoodies = false,
                chatInputHaloEnabled = false,
                overrideHotkeysWhileTyping = false,
                alwaysDisableHotkeysInChat = false,
                advancedKeybinds = false,
            }
        }
    end

    if not CommandSageDB.dbVersion or CommandSageDB.dbVersion < CURRENT_DB_VERSION then
        CommandSageDB.dbVersion = CURRENT_DB_VERSION
    end

    if not CommandSageDB.config then
        CommandSageDB.config = {}
    end

    local prefs = CommandSageDB.config.preferences
    if not prefs then
        prefs = {
            fuzzyMatchEnabled = true,
            fuzzyMatchTolerance = 2,
            maxSuggestions = 12,
            animateAutoType = true,
            showTutorialOnStartup = true,
            usageAnalytics = true,
            contextAwareness = true,
            voiceCommandEnabled = false,
            fallbackEnabled = false,
            autoTypeDelay = 0.08,
            persistHistory = true,
            snippetEnabled = true,
            contextFiltering = true,
            typeAheadPrediction = true,
            suggestionMode = "fuzzy",
            overrideHotkeysWhileTyping = true,
            favoritesSortingEnabled = true,
            autocompleteOpenDirection = "down",
            maxSuggestionsOverride = nil,
            showParamSuggestionsInColor = true,
            paramSuggestionsColor = { 1.0, 0.8, 0.0 },
            showDescriptionsInAutocomplete = true,
            terminalNavigationEnabled = true,
            advancedStyling = true,
            enableTerminalGoodies = true,
            advancedKeybinds = true,
            partialFuzzyFallback = true,
            shellContextEnabled = true,
            monetizationEnabled = false,
            macroInclusion = true,
            aceConsoleInclusion = true,
            blizzAllFallback = true,
            userCustomFallbackEnabled = false,
            uiTheme = "dark",
            uiScale = 1.0,
            autocompleteBgColor = { 0, 0, 0, 0.85 },
            autocompleteHighlightColor = { 0.6, 0.6, 0.6, 0.3 },
            tutorialFadeIn = true,
            configGuiEnabled = true,
            alwaysDisableHotkeysInChat = true,
            rainbowBorderEnabled = false,
            spinningIconEnabled = false,
            emoteStickersEnabled = false,
            usageChartEnabled = false,
            paramGlowEnabled = false,
            chatInputHaloEnabled = false,
            overrideHotkeysWhileTyping = false,
            alwaysDisableHotkeysInChat = false,
            advancedKeybinds = false,
            colorCommandEnabled = false,
            spin3DEnabled = false,
            arRuneRingEnabled = false,
            advancedEmoteEffectsEnabled = false
        }
        CommandSageDB.config.preferences = prefs
    end

    -- Example expansions if needed (safe-guard fields)
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

    self.preferences = CommandSageDB.config.preferences
end

-- Sets a configuration value.
function CommandSage_Config.Set(section, key, value)
    if section == "preferences" then
        if not CommandSageDB.config or not CommandSageDB.config.preferences then
            error("Configuration not initialized. Call InitializeDefaults() first.")
        end
        CommandSageDB.config.preferences[key] = value
    else
        error("Unknown configuration section: " .. tostring(section))
    end
end

-- Retrieves a configuration value.
function CommandSage_Config.Get(section, key)
    if section == "preferences" then
        if not CommandSageDB.config or not CommandSageDB.config.preferences then
            error("Configuration not initialized. Call InitializeDefaults() first.")
        end
        return CommandSageDB.config.preferences[key]
    else
        error("Unknown configuration section: " .. tostring(section))
    end
end

-- Resets preferences to their default values.
function CommandSage_Config:ResetPreferences()
    self:InitializeDefaults()
end

-- Expose globally so tests and other modules can see it:
_G.CommandSage_Config = CommandSage_Config

return CommandSage_Config
