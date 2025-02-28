require("tests.test_helper")

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
        -- Remove '/console' from discovered commands so that the protected branch is forced:
        local discovered = CommandSage_Discovery:GetDiscoveredCommands()
        discovered["/console"] = nil

        local oldPrint = _G.print
        local output = {}
        _G.print = function(...)
            table.insert(output, table.concat({ ... }, " "))
        end

        CommandSage_ShellContext:HandleCd("unknowntest")

        _G.print = oldPrint
        local joined = table.concat(output, "\n")
        assert.matches("No known slash command '/unknowntest' found. Context not changed.", joined)
        assert.is_nil(CommandSage_ShellContext:GetCurrentContext())

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

    it("No error if discovered commands is empty", function()
        _G.CommandSageDB = {}
        CommandSage_Trie:Clear()
        assert.has_no.errors(function()
            CommandSage_SecureCallback:ExecuteCommand("/dance", "hi")
        end)
    end)

    it("ExecuteCommand does normal slash invocation if found but no callback", function()
        assert.has_no.errors(function()
            CommandSage_SecureCallback:ExecuteCommand("/afk", "arg")
        end)
    end)

    it("protected slash but not in combat executes callback normally", function()
        _G.InCombatLockdown = function()
            return false
        end
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
