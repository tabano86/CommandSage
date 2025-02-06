-- tests/test_integration.lua
require("tests.test_helper")

describe("Integration: multiple modules working together", function()
    it("can do something that requires both the Trie and FuzzyMatch", function()
        -- Ensure the modules are loaded:
        assert.is_table(CommandSage_Trie)
        assert.is_table(CommandSage_FuzzyMatch)

        CommandSage_Trie:InsertCommand("/dance", {})
        local possible = CommandSage_Trie:AllCommands()
        local results = CommandSage_FuzzyMatch:GetSuggestions("/danc", possible)
        assert.is_true(#results > 0)
    end)
end)
