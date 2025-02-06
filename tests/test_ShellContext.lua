-- tests/test_ShellContext.lua
-- 10 tests for Core.CommandSage_ShellContext

require("busted.runner")()
require("tests.test_helper")
require("Modules.CommandSage_ShellContext")
require("Core.CommandSage_Config")
require("Core.CommandSage_Discovery")

describe("Module: CommandSage_ShellContext", function()

    before_each(function()
        _G.CommandSageDB = {}
        CommandSage_Config:InitializeDefaults()
        CommandSage_Discovery:ScanAllCommands()
    end)

    it("IsActive false by default", function()
        assert.is_false(CommandSage_ShellContext:IsActive())
    end)

    it("RewriteInputIfNeeded returns typedText if not active", function()
        local txt = CommandSage_ShellContext:RewriteInputIfNeeded("dance")
        assert.equals("dance", txt)
    end)

    it("HandleCd sets currentContext if slash is known", function()
        CommandSage_ShellContext:HandleCd("dance")
        assert.equals("dance", CommandSage_ShellContext:GetCurrentContext())
        assert.is_true(CommandSage_ShellContext:IsActive())
    end)

    it("HandleCd says 'not changed' if unknown slash", function()
        local oldPrint = print
        local output = {}
        print = function(...)
            table.insert(output, table.concat({ ... }, " "))
        end
        CommandSage_ShellContext:HandleCd("unknowntest")
        print = oldPrint
        local joined = table.concat(output, "\n")
        assert.matches("No known slash command '/unknowntest' found", joined)
        assert.is_nil(CommandSage_ShellContext:GetCurrentContext())
    end)

    it("cd .. or cd clear sets context = nil", function()
        CommandSage_ShellContext:HandleCd("dance")
        CommandSage_ShellContext:HandleCd("..")
        assert.is_nil(CommandSage_ShellContext:GetCurrentContext())
    end)

    it("RewriteInputIfNeeded adds slash + context if active", function()
        CommandSage_ShellContext:HandleCd("dance")
        local newTxt = CommandSage_ShellContext:RewriteInputIfNeeded("fancy")
        assert.equals("/dance fancy", newTxt)
    end)

    it("RewriteInputIfNeeded doesn't double slash if user typed slash", function()
        CommandSage_ShellContext:HandleCd("dance")
        local newTxt = CommandSage_ShellContext:RewriteInputIfNeeded("/already")
        assert.equals("/already", newTxt)
    end)

    it("Shell context is disabled by config => always returns typedText", function()
        CommandSage_Config.Set("preferences", "shellContextEnabled", false)
        CommandSage_ShellContext:HandleCd("dance")
        local newTxt = CommandSage_ShellContext:RewriteInputIfNeeded("test")
        assert.equals("test", newTxt)
        assert.is_false(CommandSage_ShellContext:IsActive())
    end)

    it("GetCurrentContext returns the internal var or nil", function()
        assert.is_nil(CommandSage_ShellContext:GetCurrentContext())
        CommandSage_ShellContext:HandleCd("macro")
        assert.equals("macro", CommandSage_ShellContext:GetCurrentContext())
    end)

    it("cd 'none' also clears context", function()
        CommandSage_ShellContext:HandleCd("dance")
        CommandSage_ShellContext:HandleCd("none")
        assert.is_nil(CommandSage_ShellContext:GetCurrentContext())
    end)
end)
