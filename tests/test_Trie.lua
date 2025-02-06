require("tests.test_helper")
require("Modules.CommandSage_Trie")

describe("CommandSage_Trie", function()
    before_each(function()
        CommandSage_Trie:Clear()
    end)
    it("inserts and finds prefixes", function()
        CommandSage_Trie:InsertCommand("/dance", {})
        CommandSage_Trie:InsertCommand("/da", {})
        local results = CommandSage_Trie:FindPrefix("/da")
        assert.is_true(#results >= 2)
    end)
    it("removes commands", function()
        CommandSage_Trie:InsertCommand("/macro", {})
        local r = CommandSage_Trie:FindPrefix("/macro")
        assert.equals(1, #r)
        CommandSage_Trie:RemoveCommand("/macro")
        local r2 = CommandSage_Trie:FindPrefix("/macro")
        assert.equals(0, #r2)
    end)
end)
