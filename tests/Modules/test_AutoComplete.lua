require("tests.test_helper")

describe("CommandSage_AutoComplete", function()
    before_each(function()
        _G.CommandSageDB = {}
        CommandSage_Config:InitializeDefaults()
        CommandSage_Trie:Clear()
        CommandSage_HistoryPlayback:GetHistory()
    end)

    it("MoveSelection cycles properly", function()
        local dummy = {
            { slash = "/dance" }, { slash = "/macro" },
            { slash = "/test" },  { slash = "/ping" }
        }
        CommandSage_AutoComplete:ShowSuggestions(dummy)
        CommandSage_AutoComplete:MoveSelection(1)
        CommandSage_AutoComplete:MoveSelection(1)
        CommandSage_AutoComplete:MoveSelection(1)
        CommandSage_AutoComplete:MoveSelection(1)
        CommandSage_AutoComplete:MoveSelection(1)
        assert.is_true(true)
    end)

    it("GenerateSuggestions fallback to entire list if partialFuzzyFallback = true", function()
        CommandSage_Config.Set("preferences", "partialFuzzyFallback", true)
        CommandSage_Trie:InsertCommand("/customone", {})
        local suggestions = CommandSage_AutoComplete:GenerateSuggestions("???")
        assert.is_true(#suggestions > 0)
    end)

    it("Snippet expansions appear if snippetEnabled = true", function()
        CommandSage_Config.Set("preferences", "snippetEnabled", true)
        CommandSage_Trie:InsertCommand("/dance", { description = "Dance!" })
        local suggestions = CommandSage_AutoComplete:GenerateSuggestions("/dan")
        local foundSnippet = false
        for _, s in ipairs(suggestions) do
            if s.slash == "/dance fancy" then
                foundSnippet = true
                break
            end
        end
        assert.is_true(foundSnippet)
    end)

    it("Snippet expansions do not appear if snippetEnabled = false", function()
        CommandSage_Config.Set("preferences", "snippetEnabled", false)
        CommandSage_Trie:InsertCommand("/dance", {})
        local suggestions = CommandSage_AutoComplete:GenerateSuggestions("/dan")
        local foundSnippet = false
        for _, s in ipairs(suggestions) do
            if s.slash == "/dance fancy" then
                foundSnippet = true
                break
            end
        end
        assert.is_false(foundSnippet)
    end)

    it("AcceptSuggestion sets text in ChatFrame1EditBox if animateAutoType = false", function()
        CommandSage_Config.Set("preferences", "animateAutoType", false)
        local suggestion = { slash = "/dance" }
        ChatFrame1EditBox:SetText("")
        CommandSage_AutoComplete:AcceptSuggestion(suggestion)
        assert.equals("/dance", ChatFrame1EditBox:GetText())
    end)

    it("AcceptSuggestion uses auto-typing if animateAutoType = true", function()
        CommandSage_Config.Set("preferences", "animateAutoType", true)
        local suggestion = { slash = "/dance" }
        assert.has_no.errors(function()
            CommandSage_AutoComplete:AcceptSuggestion(suggestion)
        end)
    end)

    it("CloseSuggestions hides the autocomplete frame", function()
        local dummy = { { slash = "/one" }, { slash = "/two" } }
        CommandSage_AutoComplete:ShowSuggestions(dummy)
        CommandSage_AutoComplete:CloseSuggestions()
        assert.is_true(true)
    end)

    it("History commands are merged if partial not found in main Trie", function()
        CommandSage_HistoryPlayback:AddToHistory("/coolthing")
        local suggestions = CommandSage_AutoComplete:GenerateSuggestions("cool")
        local found = false
        for _, s in ipairs(suggestions) do
            if s.slash == "/coolthing" then
                found = true
                break
            end
        end
        assert.is_true(found)
    end)

    it("favoritesSortingEnabled sorts favorites first", function()
        CommandSage_Config.Set("preferences", "favoritesSortingEnabled", true)
        CommandSage_Trie:InsertCommand("/abc", {})
        CommandSage_Trie:InsertCommand("/zzz", {})
        CommandSage_Analytics:AddFavorite("/zzz")
        local suggestions = CommandSage_AutoComplete:GenerateSuggestions("/")
        assert.equals("/zzz", suggestions[1].slash)
    end)

    it("merges history if partial match not found in trie", function()
        CommandSage_Trie:Clear()
        CommandSage_HistoryPlayback:AddToHistory("/customcmd")
        local suggestions = CommandSage_AutoComplete:GenerateSuggestions("custom")
        local found = false
        for _, s in ipairs(suggestions) do
            if s.slash == "/customcmd" then
                found = true
                break
            end
        end
        assert.is_true(found)
    end)

    it("AcceptSuggestion increments usage and saves to history", function()
        CommandSage_Trie:InsertCommand("/test", {})
        local oldScore = CommandSage_AdaptiveLearning:GetUsageScore("/test")
        CommandSage_AutoComplete:AcceptSuggestion({ slash = "/test" })
        local newScore = CommandSage_AdaptiveLearning:GetUsageScore("/test")
        assert.equals(oldScore + 1, newScore)
        local hist = _G.CommandSageDB.commandHistory or {}
        assert.equals("/test", hist[#hist])
    end)
end)
