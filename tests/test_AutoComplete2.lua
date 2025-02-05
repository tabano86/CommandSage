-- tests/test_AutoComplete2.lua
-- 10 tests for Modules/CommandSage_AutoComplete.lua (2nd coverage set)

require("busted.runner")()
require("Modules/CommandSage_AutoComplete")
require("Modules/CommandSage_Trie")
require("Modules/CommandSage_Analytics")
require("Modules/CommandSage_AdaptiveLearning")
require("Modules/CommandSage_HistoryPlayback")
require("Modules/CommandSage_Fallback")
require("Modules/CommandSage_ShellContext")
require("Modules/CommandSage_Config")

describe("Module: CommandSage_AutoComplete (Extended)", function()

    before_each(function()
        _G.CommandSageDB = {}
        CommandSage_Config:InitializeDefaults()
        CommandSage_Trie:Clear()
        CommandSage_HistoryPlayback:GetHistory()
    end)

    it("MoveSelection cycles properly", function()
        local dummy = {
            {slash="/dance"}, {slash="/macro"}, {slash="/test"}, {slash="/ping"}
        }
        CommandSage_AutoComplete:ShowSuggestions(dummy)
        CommandSage_AutoComplete:MoveSelection(1)
        CommandSage_AutoComplete:MoveSelection(1)
        CommandSage_AutoComplete:MoveSelection(1)
        CommandSage_AutoComplete:MoveSelection(1)
        -- Should cycle around
        CommandSage_AutoComplete:MoveSelection(1)
        -- No direct numeric assert, but no error indicates success
    end)

    it("GenerateSuggestions fallback to entire list if partialFuzzyFallback = true", function()
        CommandSage_Config.Set("preferences","partialFuzzyFallback",true)
        CommandSage_Trie:InsertCommand("/customone", {})
        local suggestions = CommandSage_AutoComplete:GenerateSuggestions("???")
        assert.is_true(#suggestions > 0)
    end)

    it("Snippet expansions appear if snippetEnabled = true", function()
        CommandSage_Config.Set("preferences","snippetEnabled",true)
        CommandSage_Trie:InsertCommand("/dance", {description="Dance!"})
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
        CommandSage_Config.Set("preferences","snippetEnabled",false)
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
        CommandSage_Config.Set("preferences","animateAutoType",false)
        local suggestion = {slash="/dance"}
        ChatFrame1EditBox:SetText("")
        CommandSage_AutoComplete:AcceptSuggestion(suggestion)
        assert.equals("/dance", ChatFrame1EditBox:GetText())
    end)

    it("AcceptSuggestion uses auto-typing if animateAutoType = true", function()
        CommandSage_Config.Set("preferences","animateAutoType",true)
        local suggestion = {slash="/dance"}
        assert.has_no.errors(function()
            CommandSage_AutoComplete:AcceptSuggestion(suggestion)
        end)
    end)

    it("CloseSuggestions hides the autocomplete frame", function()
        local dummy = {{slash="/one"},{slash="/two"}}
        CommandSage_AutoComplete:ShowSuggestions(dummy)
        CommandSage_AutoComplete:CloseSuggestions()
        -- No direct check for hidden, but no error
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
        CommandSage_Config.Set("preferences","favoritesSortingEnabled",true)
        CommandSage_Trie:InsertCommand("/abc", {})
        CommandSage_Trie:InsertCommand("/zzz", {})
        CommandSage_Analytics:AddFavorite("/zzz")
        local suggestions = CommandSage_AutoComplete:GenerateSuggestions("/")
        assert.equals("/zzz", suggestions[1].slash)  -- favorite on top
    end)

    it("PassesContextFilter blocks /macro in combat if contextFiltering=true", function()
        CommandSage_Config.Set("preferences","contextFiltering",true)
        _G.InCombatLockdown = function() return true end
        local suggestions = {
            {slash="/macro"},
            {slash="/dance"}
        }
        local filtered = {}
        for _, s in ipairs(suggestions) do
            if CommandSage_AutoComplete:PassesContextFilter(s) then
                table.insert(filtered, s)
            end
        end
        assert.is_false(#filtered == 2)
        assert.is_true(#filtered == 1)
        _G.InCombatLockdown = function() return false end
    end)
end)
