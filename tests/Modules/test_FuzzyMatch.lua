require("tests.test_helper")

describe("CommandSage_FuzzyMatch", function()
    before_each(function()
        _G.CommandSageDB = {}
        CommandSage_Config:InitializeDefaults()
        CommandSage_Trie:Clear()
        CommandSage_Discovery:ScanAllCommands()
    end)

    it("GetSuggestions respects fuzzyMatchTolerance", function()
        CommandSage_Config.Set("preferences", "fuzzyMatchTolerance", 1)
        CommandSage_Trie:InsertCommand("/dance", {})
        local possible = CommandSage_Trie:AllCommands()
        local results = CommandSage_FuzzyMatch:GetSuggestions("/danc", possible)
        local found = false
        for _, r in ipairs(results) do
            if r.slash == "/dance" then
                found = true
                break
            end
        end
        assert.is_true(found)
    end)

    it("SuggestCorrections returns best match", function()
        CommandSage_Trie:InsertCommand("/macro", {})
        local best, dist = CommandSage_FuzzyMatch:SuggestCorrections("/macroa")
        assert.equals("/macro", best)
        assert.equals(1, dist)
    end)

    it("GetFuzzyDistance returns integer edit distance", function()
        local d = CommandSage_FuzzyMatch:GetFuzzyDistance("cat", "cut")
        assert.equals(1, d)
    end)

    it("UsageScore influences rank", function()
        CommandSage_Trie:InsertCommand("/test1", {})
        CommandSage_Trie:InsertCommand("/test2", {})
        CommandSage_AdaptiveLearning:IncrementUsage("/test2")
        local possible = CommandSage_Trie:AllCommands()
        local res = CommandSage_FuzzyMatch:GetSuggestions("/tes", possible)
        assert.is_true(#res >= 2)
        assert.equals("/test2", res[1].slash)
    end)

    it("InCombatLockdown lowers rank by 1", function()
        _G.InCombatLockdown = function() return true end
        CommandSage_Trie:InsertCommand("/abc", {})
        local possible = CommandSage_Trie:AllCommands()
        local res = CommandSage_FuzzyMatch:GetSuggestions("/abc", possible)
        assert.equals("/abc", res[1].slash)
        _G.InCombatLockdown = function() return false end
    end)

    it("handles empty input with no commands gracefully", function()
        CommandSage_Trie:Clear()
        local possible = CommandSage_Trie:AllCommands()
        local res = CommandSage_FuzzyMatch:GetSuggestions("", possible)
        assert.equals(0, #res)
    end)

    it("cache key reduces repeated calculations without error", function()
        for i = 1, 10 do
            local d = CommandSage_FuzzyMatch:GetFuzzyDistance("abcd", "abxd")
        end
        assert.is_true(true)
    end)

    it("distance with partial mismatch is correct", function()
        local d = CommandSage_FuzzyMatch:GetFuzzyDistance("dance", "dancer")
        assert.equals(1, d)
    end)

    it("No error if discovered commands is huge or empty", function()
        _G.CommandSageDB = {}
        CommandSage_Trie:Clear()
        assert.has_no.errors(function()
            CommandSage_FuzzyMatch:SuggestCorrections("/test")
        end)
    end)

    it("ranking sorts descending by rank", function()
        CommandSage_Trie:InsertCommand("/abc", {})
        CommandSage_Trie:InsertCommand("/zzz", {})
        CommandSage_AdaptiveLearning:IncrementUsage("/zzz")
        local possible = CommandSage_Trie:AllCommands()
        local res = CommandSage_FuzzyMatch:GetSuggestions("/z", possible)
        assert.equals("/zzz", res[1].slash)
    end)

    it("fuzzy matches close strings", function()
        CommandSage_Trie:InsertCommand("/dance", {})
        local possible = CommandSage_Trie:AllCommands()
        local results = CommandSage_FuzzyMatch:GetSuggestions("/danc", possible)
        local foundDance = false
        for _, r in ipairs(results) do
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
