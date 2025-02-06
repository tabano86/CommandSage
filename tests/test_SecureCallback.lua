-- tests/test_SecureCallback.lua
-- 10 tests for Core.CommandSage_SecureCallback

require("busted.runner")()
require("tests.test_helper")
require("Modules.CommandSage_SecureCallback")
require("Core.CommandSage_Discovery")
require("Core.CommandSage_Config")

describe("Module: CommandSage_SecureCallback", function()

    before_each(function()
        _G.CommandSageDB = {}
        CommandSage_Config:InitializeDefaults()
        CommandSage_Discovery:ScanAllCommands()
    end)

    it("IsCommandProtected returns true for /console", function()
        assert.is_true(CommandSage_SecureCallback:IsCommandProtected("/console"))
        assert.is_false(CommandSage_SecureCallback:IsCommandProtected("/dance"))
    end)

    it("ExecuteCommand prints error if protected in combat", function()
        _G.InCombatLockdown = function()
            return true
        end
        local oldPrint = print
        local output = {}
        print = function(...)
            table.insert(output, table.concat({ ... }, " "))
        end
        CommandSage_SecureCallback:ExecuteCommand("/console", "arg")
        print = oldPrint
        local joined = table.concat(output, "\n")
        assert.matches("Can't run protected command in combat", joined)
        _G.InCombatLockdown = function()
            return false
        end
    end)

    it("ExecuteCommand calls callback if found in discovered commands", function()
        SlashCmdList["FAKETEST"] = function(msg)
            print("Callback invoked", msg)
        end
        _G["SLASH_FAKETEST1"] = "/faketest"
        CommandSage_Discovery:ScanAllCommands()

        local oldPrint = print
        local output = {}
        print = function(...)
            table.insert(output, table.concat({ ... }, " "))
        end

        CommandSage_SecureCallback:ExecuteCommand("/faketest", "hello")

        print = oldPrint
        local joined = table.concat(output, "\n")
        assert.matches("Callback invoked hello", joined)
    end)

    it("ExecuteCommand sets ChatFrame1EditBox if no callback found", function()
        ChatFrame1EditBox:SetText("")
        CommandSage_SecureCallback:ExecuteCommand("/notfound", "args")
        assert.equals("/notfound args", ChatFrame1EditBox:GetText())
    end)

    it("IsAnyCommandProtected detects /console in list", function()
        local cmdList = { "/dance", "/console", "/macro" }
        assert.is_true(CommandSage_SecureCallback:IsAnyCommandProtected(cmdList))
    end)

    it("IsAnyCommandProtected returns false if none are protected", function()
        local cmdList = { "/dance", "/macro" }
        assert.is_false(CommandSage_SecureCallback:IsAnyCommandProtected(cmdList))
    end)

    it("no error if discovered commands is empty", function()
        _G.CommandSageDB = {}
        CommandSage_Trie:Clear()
        assert.has_no.errors(function()
            CommandSage_SecureCallback:ExecuteCommand("/dance", "hi")
        end)
    end)

    it("ExecuteCommand does normal slash invocation if found but no callback", function()
        -- fallback style
        assert.has_no.errors(function()
            CommandSage_SecureCallback:ExecuteCommand("/afk", "arg")
        end)
    end)

    it("protected slash but not in combat => executes callback normally", function()
        _G.InCombatLockdown = function()
            return false
        end
        -- if /console had a callback discovered, it would be invoked
        -- We do minimal check
        assert.has_no.errors(function()
            CommandSage_SecureCallback:ExecuteCommand("/console", "hello")
        end)
    end)

    it("No error if slash is nil or empty", function()
        assert.has_no.errors(function()
            CommandSage_SecureCallback:ExecuteCommand(nil, "stuff")
            CommandSage_SecureCallback:ExecuteCommand("", "stuff")
        end)
    end)
end)
