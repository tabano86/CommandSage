-- File: Core/CommandSage_Config.lua
local CommandSage_Config = {}

function CommandSage_Config:InitializeDefaults()
    if not CommandSageDB or type(CommandSageDB) ~= "table" then
        CommandSageDB = {}
    end
    if not CommandSageDB.config or type(CommandSageDB.config) ~= "table" then
        CommandSageDB.config = {}
    end
    if not CommandSageDB.config.preferences or type(CommandSageDB.config.preferences) ~= "table" then
        CommandSageDB.config.preferences = {
            -- Add the fields the tests expect:
            suggestionMode = "fuzzy",        -- test_Config expects 'fuzzy'
            fuzzyMatchEnabled = true,        -- test_Config expects true
            showTutorialOnStartup = true,    -- so tutorial pops on PLAYER_LOGIN

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
            autocompleteBgColor = {0, 0, 0, 0.85},
            autocompleteHighlightColor = {0.6, 0.6, 0.6, 0.3},
            maxSuggestionsOverride = nil,
            favoritesSortingEnabled = true,
            showParamSuggestionsInColor = false,
            paramSuggestionsColor = {1, 1, 0, 1},
            showDescriptionsInAutocomplete = true,
            uiTheme = "dark",
            uiScale = 1.0,
            tutorialFadeIn = true,
            monetizationEnabled = false,
            overrideHotkeysWhileTyping = true,
            -- Some tests expect snippet expansions:
            snippetEnabled = true
        }
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
end

-- Add this method so that "/cmdsage resetprefs" and the tests can call it.
function CommandSage_Config:ResetPreferences()
    if not CommandSageDB or type(CommandSageDB) ~= "table" then
        CommandSageDB = {}
    end
    if not CommandSageDB.config or type(CommandSageDB.config) ~= "table" then
        CommandSageDB.config = {}
    end
    -- Re‐apply our default table exactly:
    CommandSageDB.config.preferences = {
        suggestionMode = "fuzzy",
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
        autocompleteBgColor = {0, 0, 0, 0.85},
        autocompleteHighlightColor = {0.6, 0.6, 0.6, 0.3},
        maxSuggestionsOverride = nil,
        favoritesSortingEnabled = true,
        showParamSuggestionsInColor = false,
        paramSuggestionsColor = {1, 1, 0, 1},
        showDescriptionsInAutocomplete = true,
        uiTheme = "dark",
        uiScale = 1.0,
        tutorialFadeIn = true,
        monetizationEnabled = false,
        overrideHotkeysWhileTyping = true,
        snippetEnabled = true
    }
    print("CommandSage_Config: preferences reset to default.")
end

_G.CommandSage_Config = CommandSage_Config
return CommandSage_Config
