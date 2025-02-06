-- tests/test_DeveloperAPI.lua
-- 10 tests for Modules.CommandSage_DeveloperAPI

require("busted.runner")()
require("tests.test_helper")

require("Modules.CommandSage_DeveloperAPI")
require("Core.CommandSage_Discovery")  -- was previously "CORE.CommandSage_Discovery"
require("Core.CommandSage_Config")
require("Modules.CommandSage_Trie")

describe("Module: CommandSage_DeveloperAPI", function()

    before_each(function()
        _G.CommandSageDB = {}
        CommandSage_Config:InitializeDefaults()
        CommandSage_Trie:Clear()
        CommandSage_Discovery:ScanAllCommands()
    end)

    it("DebugDump prints discovered commands count", function()
        assert.has_no.errors(function()
            CommandSage_DeveloperAPI:DebugDump()
        end)
    end)

    it("ForceReindex calls ScanAllCommands again", function()
        local oldScan = CommandSage_Discovery.ScanAllCommands
        local called = 0
        CommandSage_Discovery.ScanAllCommands = function(...)
            called = called + 1
            return oldScan(...)
        end
        CommandSage_DeveloperAPI:ForceReindex()
        assert.equals(1, called)
        CommandSage_Discovery.ScanAllCommands = oldScan
    end)

    it("GetAllCommands returns discovered slash commands", function()
        local all = CommandSage_DeveloperAPI:GetAllCommands()
        assert.is_table(all)
        assert.is_not_nil(all["/dance"])
    end)

    it("Subscribe and FireEvent triggers callback", function()
        local triggered = false
        CommandSage_DeveloperAPI:Subscribe("COMMANDS_UPDATED", function(...) triggered = true end)
        CommandSage_DeveloperAPI:FireEvent("COMMANDS_UPDATED")
        assert.is_true(triggered)
    end)

    it("RegisterCommand inserts new slash into discovered + trie", function()
        CommandSage_DeveloperAPI:RegisterCommand("/mycmd", function() end, "desc", "cat")
        local all = CommandSage_DeveloperAPI:GetAllCommands()
        assert.is_not_nil(all["/mycmd"])
    end)

    it("UnregisterCommand removes from discovered + trie", function()
        CommandSage_DeveloperAPI:RegisterCommand("/mycmd", function() end)
        CommandSage_DeveloperAPI:UnregisterCommand("/mycmd")
        local all = CommandSage_DeveloperAPI:GetAllCommands()
        assert.is_nil(all["/mycmd"])
    end)

    it("Firing an event with multiple callbacks calls them all", function()
        local count = 0
        CommandSage_DeveloperAPI:Subscribe("TEST_MULTI", function() count = count + 1 end)
        CommandSage_DeveloperAPI:Subscribe("TEST_MULTI", function() count = count + 1 end)
        CommandSage_DeveloperAPI:FireEvent("TEST_MULTI")
        assert.equals(2, count)
    end)

    it("ListAllEvents returns array of subscribed event names", function()
        CommandSage_DeveloperAPI:Subscribe("X_EVENT", function() end)
        local evts = CommandSage_DeveloperAPI:ListAllEvents()
        assert.is_true(#evts >= 1)
    end)

    it("UnregisterCommand on nonexisting slash is safe", function()
        assert.has_no.errors(function()
            CommandSage_DeveloperAPI:UnregisterCommand("/notfound")
        end)
    end)

    it("RegisterCommand with blank slash does nothing", function()
        CommandSage_DeveloperAPI:RegisterCommand("", function() end)
        -- no error => success
    end)
end)
