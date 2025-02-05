-- tests\test_AutoComplete.lua
require("Modules.CommandSage_AutoComplete")
require("Modules.CommandSage_Trie")
require("Modules.CommandSage_ParameterHelper")
require("Modules.CommandSage_Analytics")
require("Modules.CommandSage_HistoryPlayback")
require("Modules.CommandSage_Fallback")
require("Modules.CommandSage_AdaptiveLearning")
require("Modules.CommandSage_ShellContext")
require("Modules.CommandSage_Config")

describe("CommandSage_AutoComplete", function()
    before_each(function()
        _G.CommandSageDB = {}
        CommandSage_Config:InitializeDefaults()
        CommandSage_Trie:Clear()
        CommandSage_HistoryPlayback:GetHistory()
    end)

    it("generates suggestions from trie prefix", function()
        CommandSage_Trie:InsertCommand("/dance", {})
        local suggestions = CommandSage_AutoComplete:GenerateSuggestions("/dan")
        assert.is_true(#suggestions >= 1)
    end)

    it("merges history if partial match not found in trie", function()
        CommandSage_Trie:Clear()
        CommandSage_HistoryPlayback:AddToHistory("/customcmd")

        local suggestions = CommandSage_AutoComplete:GenerateSuggestions("custom")
        local found = false
        for _, s in ipairs(suggestions) do
            if s.slash == "/customcmd" then
                found = true
            end
        end
        assert.is_true(found)
    end)

    it("AcceptSuggestion increments usage and saves to history", function()
        CommandSage_Trie:InsertCommand("/test", {})
        local oldScore = CommandSage_AdaptiveLearning:GetUsageScore("/test")

        CommandSage_AutoComplete:AcceptSuggestion({slash="/test"})

        local newScore = CommandSage_AdaptiveLearning:GetUsageScore("/test")
        assert.equals(oldScore + 1, newScore)

        local hist = _G.CommandSageDB.commandHistory or {}
        assert.equals("/test", hist[#hist])
    end)
end)
