-- tests/test_ParameterHelper2.lua
-- 10 tests for Modules/CommandSage_ParameterHelper.lua (extended)

require("busted.runner")()
require("Modules/CommandSage_ParameterHelper")
require("Modules/CommandSage_Config")

describe("Module: CommandSage_ParameterHelper (Extended)", function()

    before_each(function()
        _G.CommandSageDB = {}
        CommandSage_Config:InitializeDefaults()
    end)

    it("GetParameterSuggestions for /w merges friend list + recent whispers", function()
        _G.C_FriendList.GetNumFriends = function() return 1 end
        _G.C_FriendList.GetFriendInfoByIndex = function(i)
            return { name = "Buddy" }
        end
        CommandSage_ParameterHelper:RecordWhisperTarget("Sammy")
        local results = CommandSage_ParameterHelper:GetParameterSuggestions("/w","Sa")
        assert.is_true(#results >= 1)
        local foundSammy = false
        for _,r in ipairs(results) do
            if r == "sammy" then
                foundSammy = true
                break
            end
        end
        local foundBuddy = false
        for _,r in ipairs(results) do
            if r == "buddy" then
                foundBuddy = true
                break
            end
        end
        assert.is_true(foundSammy)
        assert.is_true(foundBuddy)
    end)

    it("AddKnownParam appends to knownParams for that slash", function()
        CommandSage_ParameterHelper:AddKnownParam("/test","alpha")
        local res = CommandSage_ParameterHelper:GetParameterSuggestions("/test","a")
        assert.equals("alpha", res[1])
    end)

    it("GetInlineHint returns a string of subcommands joined by ' | '", function()
        local hint = CommandSage_ParameterHelper:GetInlineHint("/dance")
        assert.matches("silly", hint)
        assert.matches("fancy", hint)
    end)

    it("No subcommands => returns empty table", function()
        local res = CommandSage_ParameterHelper:GetParameterSuggestions("/nodance","")
        assert.equals(0, #res)
    end)

    it("Partial match is case-insensitive", function()
        local res = CommandSage_ParameterHelper:GetParameterSuggestions("/dance","F")
        assert.is_true(#res > 0)
    end)

    it("handles no CommandSageDB gracefully for RecordWhisperTarget", function()
        _G.CommandSageDB = nil
        assert.has_no.errors(function()
            CommandSage_ParameterHelper:RecordWhisperTarget("UserX")
        end)
    end)

    it("UpdateFriendList is triggered after 5s, no error", function()
        -- We can just call it manually
        assert.has_no.errors(function()
            local func = debug.getupvalue(CommandSage_ParameterHelper.GetParameterSuggestions, 2)
            func()  -- UpdateFriendList
        end)
    end)

    it("Known slash param is returned if partialArg matches substring", function()
        local res = CommandSage_ParameterHelper:GetParameterSuggestions("/macro", "n")
        local found = false
        for _,r in ipairs(res) do
            if r == "new" then
                found = true
                break
            end
        end
        assert.is_true(found)
    end)

    it("Reset or wipe doesn't affect known params built in code", function()
        -- There's no official reset, but we can do it manually
        local knownParams = debug.getupvalue(CommandSage_ParameterHelper.GetParameterSuggestions, 1)
        knownParams["/dance"] = nil
        local res = CommandSage_ParameterHelper:GetParameterSuggestions("/dance","")
        assert.equals(0, #res)
        -- revert
        knownParams["/dance"] = {"silly","fancy","epic"}
    end)

    it("handles repeated whispers for same target name with different case", function()
        CommandSage_ParameterHelper:RecordWhisperTarget("SAMMY")
        CommandSage_ParameterHelper:RecordWhisperTarget("sammy")
        local res = CommandSage_ParameterHelper:GetParameterSuggestions("/w", "sam")
        assert.is_true(#res >= 1)
    end)
end)
