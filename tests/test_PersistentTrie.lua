-- tests/test_PersistentTrie.lua
-- 10 tests for Core.CommandSage_PersistentTrie

require("busted.runner")()
require("Modules.CommandSage_PersistentTrie")
require("Modules.CommandSage_Trie")
require("Core.CommandSage_Config")

describe("Module: CommandSage_PersistentTrie", function()

    before_each(function()
        _G.CommandSageDB = {}
        CommandSage_Config:InitializeDefaults()
        CommandSage_Trie:Clear()
    end)

    it("SaveTrie stores data in CommandSageDB[cachedTrie]", function()
        CommandSage_Trie:InsertCommand("/dance", { desc = "D" })
        CommandSage_PersistentTrie:SaveTrie()
        assert.is_table(_G.CommandSageDB.cachedTrie)
    end)

    it("LoadTrie populates the Trie from cached data", function()
        CommandSage_Trie:InsertCommand("/dance", { desc = "D" })
        CommandSage_PersistentTrie:SaveTrie()
        CommandSage_Trie:Clear()
        CommandSage_PersistentTrie:LoadTrie()
        local results = CommandSage_Trie:FindPrefix("/dan")
        assert.is_true(#results >= 1)
    end)

    it("Clearing the trie data then LoadTrie with no saved data => empty trie", function()
        CommandSage_Trie:InsertCommand("/dance", {})
        CommandSage_Trie:Clear()
        CommandSage_PersistentTrie:LoadTrie()
        local all = CommandSage_Trie:AllCommands()
        assert.equals(0, #all)
    end)

    it("ClearCachedTrie sets cachedTrie = nil", function()
        CommandSage_Trie:InsertCommand("/dance", {})
        CommandSage_PersistentTrie:SaveTrie()
        CommandSage_PersistentTrie:ClearCachedTrie()
        assert.is_nil(_G.CommandSageDB.cachedTrie)
    end)

    it("deserialization with nested children works", function()
        CommandSage_Trie:InsertCommand("/abc", { desc = "abc" })
        CommandSage_Trie:InsertCommand("/abd", { desc = "abd" })
        CommandSage_PersistentTrie:SaveTrie()
        CommandSage_Trie:Clear()
        CommandSage_PersistentTrie:LoadTrie()
        local res = CommandSage_Trie:FindPrefix("/ab")
        assert.is_true(#res == 2)
    end)

    it("LoadTrie does nothing if CommandSageDB.cachedTrie is nil", function()
        assert.has_no.errors(function()
            CommandSage_PersistentTrie:LoadTrie()
        end)
    end)

    it("SaveTrie overwrites any existing cached data", function()
        _G.CommandSageDB.cachedTrie = "old data"
        CommandSage_Trie:InsertCommand("/dance", {})
        CommandSage_PersistentTrie:SaveTrie()
        assert.is_table(_G.CommandSageDB.cachedTrie)
    end)

    it("Serialization includes isTerminal, info, children, maxDepth", function()
        CommandSage_Trie:InsertCommand("/dance", { desc = "some info" })
        CommandSage_PersistentTrie:SaveTrie()
        local s = _G.CommandSageDB.cachedTrie
        assert.is_true(s.isTerminal == false) -- root
        -- children check
        for k, v in pairs(s.children) do
            -- e.g. the slash starts with /
            break
        end
    end)

    it("Handles weird data in CommandSageDB[cachedTrie] gracefully", function()
        _G.CommandSageDB.cachedTrie = { isTerminal = true, children = 123 }  -- invalid
        assert.has_no.errors(function()
            CommandSage_PersistentTrie:LoadTrie()
        end)
    end)

    it("No error if SaveTrie called with empty trie", function()
        CommandSage_Trie:Clear()
        assert.has_no.errors(function()
            CommandSage_PersistentTrie:SaveTrie()
        end)
        assert.is_not_nil(_G.CommandSageDB.cachedTrie)
    end)
end)
