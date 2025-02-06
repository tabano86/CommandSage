--==========================
-- tests/test_integration.lua
--==========================
-- Example "integration" or multi-module test. This is optional; you can keep
-- your current structure or expand as needed.

describe("Integration: multiple modules working together", function()
    it("can do something that requires both the Trie and FuzzyMatch", function()
        -- For demonstration:
        CommandSage_Trie:InsertCommand("/dance", {})
        local possible = CommandSage_Trie:AllCommands()
        local results = CommandSage_FuzzyMatch:GetSuggestions("/danc", possible)
        assert.is_true(#results > 0)
    end)
end)
