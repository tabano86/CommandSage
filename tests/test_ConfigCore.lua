-- tests/test_ConfigCore.lua
-- 10 tests for CommandSage_Config.lua (Core)
require("Core/CommandSage_Config")

describe("Core: CommandSage_Config", function()

    before_each(function()
        _G.CommandSageDB = {}
    end)

    it("initializes defaults with correct fields", function()
        CommandSage_Config:InitializeDefaults()
        local prefs = _G.CommandSageDB.config.preferences
        assert.is_truthy(prefs)
        assert.is_true(prefs.fuzzyMatchEnabled)
        assert.equals("fuzzy", prefs.suggestionMode)
    end)

    it("sets DB version to CURRENT_DB_VERSION", function()
        CommandSage_Config:InitializeDefaults()
        local version = _G.CommandSageDB.dbVersion
        assert.is_truthy(version)
        assert.equals(5, version)  -- Adjust if your CURRENT_DB_VERSION changes
    end)

    it("can retrieve a nested config key", function()
        CommandSage_Config:InitializeDefaults()
        local val = CommandSage_Config.Get("preferences", "uiTheme")
        assert.equals("dark", val)
    end)

    it("can set a nested config key", function()
        CommandSage_Config:InitializeDefaults()
        CommandSage_Config.Set("preferences", "uiTheme", "classic")
        local val = CommandSage_Config.Get("preferences", "uiTheme")
        assert.equals("classic", val)
    end)

    it("resets preferences properly", function()
        CommandSage_Config:InitializeDefaults()
        CommandSage_Config.Set("preferences", "uiTheme", "light")
        CommandSage_Config:ResetPreferences()
        assert.equals("dark", CommandSage_Config.Get("preferences", "uiTheme"))
    end)

    it("assigns newly introduced feature toggles if missing", function()
        CommandSage_Config:InitializeDefaults()
        local prefs = _G.CommandSageDB.config.preferences
        assert.is_boolean(prefs.rainbowBorderEnabled)
        assert.is_boolean(prefs.spinningIconEnabled)
        assert.is_boolean(prefs.emoteStickersEnabled)
    end)

    it("handles a missing CommandSageDB gracefully", function()
        _G.CommandSageDB = nil
        assert.has_no.errors(function()
            CommandSage_Config:InitializeDefaults()
        end)
    end)

    it("does not overwrite existing preferences except if missing", function()
        _G.CommandSageDB = {
            dbVersion = 99,
            config = {
                preferences = {
                    fuzzyMatchEnabled = false,
                    uiTheme = "light",
                }
            }
        }
        CommandSage_Config:InitializeDefaults()
        local prefs = _G.CommandSageDB.config.preferences
        -- fuzzyMatchEnabled remains false
        assert.is_false(prefs.fuzzyMatchEnabled)
        -- new toggles are added
        assert.is_not_nil(prefs.spinningIconEnabled)
        -- version updated
        assert.equals(5, _G.CommandSageDB.dbVersion)
    end)

    it("Set() and Get() return nil if config tables missing entirely", function()
        _G.CommandSageDB = {}
        local v = CommandSage_Config.Get("preferences", "testKey")
        assert.is_nil(v)
        CommandSage_Config.Set("preferences", "testKey", 123)
        -- now it should exist
        local v2 = CommandSage_Config.Get("preferences", "testKey")
        assert.equals(123, v2)
    end)

    it("printing after reset does not error", function()
        CommandSage_Config:InitializeDefaults()
        assert.has_no.errors(function()
            CommandSage_Config:ResetPreferences()
        end)
    end)
end)
