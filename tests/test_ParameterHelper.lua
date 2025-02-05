-- tests\test_ParameterHelper.lua
require("Modules/CommandSage_ParameterHelper")
require("Modules/CommandSage_Config")

describe("CommandSage_ParameterHelper", function()
    before_each(function()
        _G.CommandSageDB = {}
        CommandSage_Config:InitializeDefaults()
    end)

    it("suggests /dance params", function()
        local results = CommandSage_ParameterHelper:GetParameterSuggestions("/dance", "f")
        assert.not_equals(0, #results)
        local foundFancy = false
        for _,r in ipairs(results) do
            if r == "fancy" then
                foundFancy = true
            end
        end
        assert.is_true(foundFancy)
    end)

    it("returns empty for unknown slash", function()
        local results = CommandSage_ParameterHelper:GetParameterSuggestions("/unknown", "")
        assert.equals(0, #results)
    end)

    it("handles whisper suggestions", function()
        CommandSage_ParameterHelper:RecordWhisperTarget("Sammy")
        local results = CommandSage_ParameterHelper:GetParameterSuggestions("/w", "Sam")
        assert.is_true(#results > 0)
        assert.equals("sammy", results[1])
    end)
end)
