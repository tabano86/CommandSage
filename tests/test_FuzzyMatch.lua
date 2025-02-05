-- tests\test_FuzzyMatch.lua
require("Modules.CommandSage_FuzzyMatch")
require("Modules.CommandSage_Trie")
require("CommandSage_AdaptiveLearning")
require("Modules.CommandSage_Config")
require("Modules.CommandSage_Discovery")

describe("CommandSage_FuzzyMatch", function()
    before_each(function()
        _G.CommandSageDB = {}
        CommandSage_Config:InitializeDefaults()
        CommandSage_Trie:Clear()
    end)

    it("fuzzy matches close strings", function()
        CommandSage_Trie:InsertCommand("/dance", {})
        local possible = CommandSage_Trie:AllCommands()
        local results = CommandSage_FuzzyMatch:GetSuggestions("/danc", possible)
        local foundDance = false
        for _,r in ipairs(results) do
            if r.slash == "/dance" then
                foundDance = true
            end
        end
        assert.is_true(foundDance)
    end)

    it("SuggestCorrections returns best slash for near input", function()
        CommandSage_Trie:InsertCommand("/macro", {})
        local best, dist = CommandSage_FuzzyMatch:SuggestCorrections("/macr")
        assert.equals("/macro", best)
        assert.is_true(dist <= 1)
    end)
end)
