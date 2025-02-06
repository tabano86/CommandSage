-- File: Core/CommandSage_Config.lua
local CommandSage_Config = {}
local CURRENT_DB_VERSION = 1

-- Initializes default configuration values.
function CommandSage_Config:InitializeDefaults()
    -- If CommandSageDB is not a table or is empty, reinitialize it.
    if type(CommandSageDB) ~= "table" or next(CommandSageDB) == nil then
        CommandSageDB = {}
    end

    if not CommandSageDB.dbVersion or CommandSageDB.dbVersion < CURRENT_DB_VERSION then
        CommandSageDB.dbVersion = CURRENT_DB_VERSION
    end

    if not CommandSageDB.config or next(CommandSageDB.config or {}) == nil then
        CommandSageDB.config = {}
    end

    if not CommandSageDB.config.preferences then
        CommandSageDB.config.preferences = {
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
    end

    self.preferences = CommandSageDB.config.preferences
end

function CommandSage_Config:ResetPreferences()
    if CommandSageDB and CommandSageDB.config then
        CommandSageDB.config.preferences = nil
    end
    self:InitializeDefaults()
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

-- Expose globally so tests and other modules can see it:
_G.CommandSage_Config = CommandSage_Config

return CommandSage_Config
