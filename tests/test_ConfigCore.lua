-- tests/test_ConfigCore.lua
-- Another small check for CommandSage_Config

require("busted.runner")()
require("tests.test_helper")

require("Core.CommandSage_Config")

describe("Core: CommandSage_Config",function()
    before_each(function()
        _G.CommandSageDB={}
    end)

    it("initializes defaults",function()
        CommandSage_Config:InitializeDefaults()
        local prefs=_G.CommandSageDB.config.preferences
        assert.is_truthy(prefs)
        assert.equals("fuzzy",prefs.suggestionMode)
    end)

    it("sets and gets config values",function()
        CommandSage_Config:InitializeDefaults()
        CommandSage_Config.Set("preferences","uiTheme","light")
        local v=CommandSage_Config.Get("preferences","uiTheme")
        assert.equals("light",v)
    end)
end)
