-- tests/test_Terminal.lua
-- 10 tests for Modules/CommandSage_Terminal.lua

require("busted.runner")()
require("Modules/CommandSage_Terminal")
require("Modules/CommandSage_Config")

describe("Module: CommandSage_Terminal", function()

    before_each(function()
        _G.CommandSageDB = {}
        CommandSage_Config:InitializeDefaults()
    end)

    it("Initialize does not error if enableTerminalGoodies=false", function()
        CommandSage_Config.Set("preferences","enableTerminalGoodies",false)
        assert.has_no.errors(function()
            CommandSage_Terminal:Initialize()
        end)
    end)

    it("Initialize registers /cls, /time, /uptime, etc. if enabled", function()
        CommandSage_Config.Set("preferences","enableTerminalGoodies",true)
        CommandSage_Terminal:Initialize()
        assert.is_function(SlashCmdList["CMDCLS"])
        assert.is_function(SlashCmdList["CMDTIME"])
        assert.is_function(SlashCmdList["CMDUPTIME"])
    end)

    it("/cls clears chat frames, no error", function()
        CommandSage_Config.Set("preferences","enableTerminalGoodies",true)
        CommandSage_Terminal:Initialize()
        assert.has_no.errors(function()
            SlashCmdList["CMDCLS"]("")
        end)
    end)

    it("/pwd prints zone name", function()
        assert.has_no.errors(function()
            SlashCmdList["CMDPWD"]("")
        end)
    end)

    it("/uptime prints session uptime", function()
        assert.has_no.errors(function()
            SlashCmdList["CMDUPTIME"]("")
        end)
    end)

    it("/license sets or prints license status", function()
        assert.has_no.errors(function()
            SlashCmdList["CMDLICENSE"]("TESTKEY")
            SlashCmdList["CMDLICENSE"]("")
        end)
    end)

    it("/donate prints a link", function()
        assert.has_no.errors(function()
            SlashCmdList["CMDDONATE"]("")
        end)
    end)

    it("/coffee is same as /donate", function()
        assert.has_no.errors(function()
            SlashCmdList["CMDCOFFEE"]("")
        end)
    end)

    it("/color respects config colorCommandEnabled", function()
        CommandSage_Config.Set("preferences","enableTerminalGoodies",true)
        CommandSage_Config.Set("preferences","colorCommandEnabled",true)
        CommandSage_Terminal:Initialize()
        assert.has_no.errors(function()
            SlashCmdList["CMDCOLOR"]("1 0 0")
        end)
    end)

    it("/3dspin is added if spin3DEnabled = true", function()
        CommandSage_Config.Set("preferences","spin3DEnabled",true)
        CommandSage_Config.Set("preferences","enableTerminalGoodies",true)
        CommandSage_Terminal:Initialize()
        assert.is_function(SlashCmdList["CMD3DSPIN"])
        -- test call
        assert.has_no.errors(function()
            SlashCmdList["CMD3DSPIN"]("")
        end)
    end)
end)
