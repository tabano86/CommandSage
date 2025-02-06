-- tests/test_Config.lua
-- Basic checks for Core.CommandSage_Config

require("busted.runner")()
require("tests.test_helper")

require("Core.CommandSage_Config")

describe("CommandSage_Config Tests", function()
    before_each(function()
        _G.CommandSageDB = {}
    end)

    it("initializes defaults if none set", function()
        assert.is_nil(_G.CommandSageDB.config)
        CommandSage_Config:InitializeDefaults()
        assert.is_not_nil(_G.CommandSageDB.config.preferences)
        assert.equals("fuzzy", _G.CommandSageDB.config.preferences.suggestionMode)
    end)

    it("retrieves existing config values", function()
        CommandSage_Config:InitializeDefaults()
        local val = CommandSage_Config.Get("preferences", "fuzzyMatchEnabled")
        assert.is_true(val)
    end)

    it("sets config values", function()
        CommandSage_Config:InitializeDefaults()
        CommandSage_Config.Set("preferences", "uiTheme", "light")
        local v = CommandSage_Config.Get("preferences", "uiTheme")
        assert.equals("light", v)
    end)

    it("resets preferences to default", function()
        CommandSage_Config:InitializeDefaults()
        CommandSage_Config.Set("preferences", "uiTheme", "light")
        assert.equals("light", CommandSage_Config.Get("preferences", "uiTheme"))

        CommandSage_Config:ResetPreferences()
        assert.equals("dark", CommandSage_Config.Get("preferences", "uiTheme"))
    end)
end)
