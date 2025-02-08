-- File: Core/CommandSage_Config.lua
local CommandSage_Config = {}

-- Internal function for migrating legacy configurations.
local function MigrateConfig(oldPrefs)
    -- Example migration: ensure uiTheme is one of the allowed values.
    if oldPrefs.uiTheme and not (oldPrefs.uiTheme == "dark" or oldPrefs.uiTheme == "light" or oldPrefs.uiTheme == "classic") then
        oldPrefs.uiTheme = "dark"
    end
    -- Additional migrations can be added here.
    return oldPrefs
end

function CommandSage_Config:InitializeDefaults()
    if not CommandSageDB or type(CommandSageDB) ~= "table" then
        CommandSageDB = {}
    end
    if not CommandSageDB.config or type(CommandSageDB.config) ~= "table" then
        CommandSageDB.config = {}
    end
    if not CommandSageDB.config.preferences or type(CommandSageDB.config.preferences) ~= "table" then
        CommandSageDB.config.preferences = {
            -- Basic preferences
            suggestionMode = "fuzzy",         -- 'fuzzy' or 'strict'
            fuzzyMatchEnabled = true,
            showTutorialOnStartup = true,

            animateAutoType = false,
            autoTypeDelay = 0.1,
            fuzzyMatchTolerance = 2,
            partialFuzzyFallback = true,
            advancedKeybinds = true,
            persistHistory = true,
            shellContextEnabled = true,
            blizzAllFallback = true,
            usageChartEnabled = false,
            colorCommandEnabled = true,
            spin3DEnabled = false,
            arRuneRingEnabled = false,
            emoteStickersEnabled = false,
            advancedStyling = true,
            autocompleteBgColor = { 0, 0, 0, 0.85 },
            autocompleteHighlightColor = { 0.6, 0.6, 0.6, 0.3 },
            maxSuggestionsOverride = nil,
            favoritesSortingEnabled = true,
            showParamSuggestionsInColor = false,
            paramSuggestionsColor = { 1, 1, 0, 1 },
            showDescriptionsInAutocomplete = true,
            uiTheme = "dark",
            uiScale = 1.0,
            tutorialFadeIn = true,
            monetizationEnabled = false,
            overrideHotkeysWhileTyping = true,
            snippetEnabled = true
        }
    else
        -- Migrate legacy preferences if needed.
        CommandSageDB.config.preferences = MigrateConfig(CommandSageDB.config.preferences)
    end
end

function CommandSage_Config.Get(section, key)
    if CommandSageDB and CommandSageDB.config and CommandSageDB.config[section] then
        return CommandSageDB.config[section][key]
    end
    return nil
end

function CommandSage_Config.Set(section, key, value)
    if not CommandSageDB or type(CommandSageDB) ~= "table" then
        CommandSageDB = {}
    end
    if not CommandSageDB.config or type(CommandSageDB.config) ~= "table" then
        CommandSageDB.config = {}
    end
    if not CommandSageDB.config[section] then
        CommandSageDB.config[section] = {}
    end
    CommandSageDB.config[section][key] = value
    -- Optionally, fire a configuration update event
    if CommandSage_DeveloperAPI and CommandSage_DeveloperAPI.FireEvent then
        CommandSage_DeveloperAPI:FireEvent("CONFIG_CHANGED", section, key, value)
    end
end

-- Reset preferences to defaults (with full logging)
function CommandSage_Config:ResetPreferences()
    if not CommandSageDB or type(CommandSageDB) ~= "table" then
        CommandSageDB = {}
    end
    if not CommandSageDB.config or type(CommandSageDB.config) ~= "table" then
        CommandSageDB.config = {}
    end
    CommandSage_Config:InitializeDefaults()
    print("CommandSage_Config: preferences reset to default.")
    if CommandSage_DeveloperAPI and CommandSage_DeveloperAPI.FireEvent then
        CommandSage_DeveloperAPI:FireEvent("CONFIG_RESET")
    end
end

_G.CommandSage_Config = CommandSage_Config
return CommandSage_Config
