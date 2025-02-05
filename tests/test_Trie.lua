-- tests\test_Trie.lua
require("Modules/CommandSage_Trie")

describe("CommandSage_Trie", function()
    before_each(function()
        CommandSage_Trie:Clear()
    end)

    it("inserts and finds prefixes", function()
        CommandSage_Trie:InsertCommand("/dance", {desc="Dance"})
        CommandSage_Trie:InsertCommand("/da", {desc="DA"})
        local results = CommandSage_Trie:FindPrefix("/da")
        assert.is_true(#results >= 2)
    end)

    it("removes commands properly", function()
        CommandSage_Trie:InsertCommand("/macro", {})
        local results = CommandSage_Trie:FindPrefix("/macro")
        assert.equals(1, #results)

        CommandSage_Trie:RemoveCommand("/macro")
        local results2 = CommandSage_Trie:FindPrefix("/macro")
        assert.equals(0, #results2)
    end)

    it("gathers all commands", function()
        CommandSage_Trie:InsertCommand("/test1", {})
        CommandSage_Trie:InsertCommand("/test2", {})
        local all = CommandSage_Trie:AllCommands()
        assert.equals(2, #all)
    end)
end)
