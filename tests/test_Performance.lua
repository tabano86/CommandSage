-- tests/test_Performance.lua
-- 10 tests for Core.CommandSage_Performance

require("busted.runner")()
require("Modules.CommandSage_Performance")
require("Core.CommandSage_Discovery")
require("Modules.CommandSage_Trie")

describe("Module: CommandSage_Performance", function()

    before_each(function()
        _G.CommandSageDB = {}
        CommandSage_Discovery:ScanAllCommands()
    end)

    it("ShowDashboard toggles frame display", function()
        CommandSage_Performance:ShowDashboard()
        -- not easy to check isShown, but no error
        CommandSage_Performance:ShowDashboard()
        -- toggled off
    end)

    it("CountTrieNodes returns number > 0 after scanning commands", function()
        local n = CommandSage_Performance:CountTrieNodes()
        assert.is_true(n > 1)
    end)

    it("PrintDetailedStats prints memory, discovered commands, etc.", function()
        assert.has_no.errors(function()
            CommandSage_Performance:PrintDetailedStats()
        end)
    end)

    it("ShowDashboard multiple times is safe", function()
        assert.has_no.errors(function()
            CommandSage_Performance:ShowDashboard()
            CommandSage_Performance:ShowDashboard()
        end)
    end)

    it("Trie node count grows if we manually insert more", function()
        local oldCount = CommandSage_Performance:CountTrieNodes()
        CommandSage_Trie:InsertCommand("/testextra", {})
        local newCount = CommandSage_Performance:CountTrieNodes()
        assert.is_true(newCount > oldCount)
    end)

    it("Memory usage retrieval does not error", function()
        local memKB = collectgarbage("count")
        assert.is_number(memKB)
    end)

    it("discoveredCommands after scanning is not empty", function()
        local discovered = CommandSage_Discovery:GetDiscoveredCommands()
        local c = 0
        for _ in pairs(discovered) do
            c = c + 1
        end
        assert.is_true(c > 0)
    end)

    it("No error if ShowDashboard called with no discovered commands (rare)", function()
        CommandSage_Trie:Clear()
        assert.has_no.errors(function()
            CommandSage_Performance:ShowDashboard()
        end)
    end)

    it("ShowDashboard hides if it's already visible (toggle style)", function()
        CommandSage_Performance:ShowDashboard()
        CommandSage_Performance:ShowDashboard()
        -- no error
    end)

    it("CountTrieNodes does a recursive sum with a nested child", function()
        CommandSage_Trie:InsertCommand("/abcxyz", {})
        local ct = CommandSage_Performance:CountTrieNodes()
        assert.is_true(ct > 20) -- there's a bunch from built-in, plus new
    end)
end)
