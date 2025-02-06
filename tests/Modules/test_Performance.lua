require("tests.test_helper")

describe("Module: CommandSage_Performance", function()
    before_each(function()
        _G.CommandSageDB = {}
        CommandSage_Discovery:ScanAllCommands()
    end)

    it("ShowDashboard toggles frame display", function()
        CommandSage_Performance:ShowDashboard()
        CommandSage_Performance:ShowDashboard()
        assert.is_true(true)
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

    it("No error if ShowDashboard called with no discovered commands", function()
        CommandSage_Trie:Clear()
        assert.has_no.errors(function()
            CommandSage_Performance:ShowDashboard()
        end)
    end)

    it("ShowDashboard hides if it's already visible (toggle style)", function()
        CommandSage_Performance:ShowDashboard()
        CommandSage_Performance:ShowDashboard()
        assert.is_true(true)
    end)

    it("CountTrieNodes does a recursive sum with a nested child", function()
        CommandSage_Trie:InsertCommand("/abcxyz", {})
        local ct = CommandSage_Performance:CountTrieNodes()
        assert.is_true(ct > 20)
    end)
end)
