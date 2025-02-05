-- tests/test_AdaptiveLearning.lua
-- 10 tests for Modules.CommandSage_AdaptiveLearning

require("busted.runner")()
require("tests.test_helper")

require("Modules.CommandSage_AdaptiveLearning")
require("Core.CommandSage_Config")

describe("Module: CommandSage_AdaptiveLearning", function()

    before_each(function()
        _G.CommandSageDB = {}
        CommandSage_Config:InitializeDefaults()
    end)

    it("usageData is created upon increment", function()
        assert.is_nil(_G.CommandSageDB.usageData)
        CommandSage_AdaptiveLearning:IncrementUsage("/test")
        assert.is_table(_G.CommandSageDB.usageData)
    end)

    it("IncrementUsage increments numeric usage", function()
        CommandSage_AdaptiveLearning:IncrementUsage("/test")
        assert.equals(1, _G.CommandSageDB.usageData["/test"])
        CommandSage_AdaptiveLearning:IncrementUsage("/test")
        assert.equals(2, _G.CommandSageDB.usageData["/test"])
    end)

    it("GetUsageScore returns 0 if not used", function()
        local s = CommandSage_AdaptiveLearning:GetUsageScore("/dance")
        assert.equals(0, s)
    end)

    it("GetUsageScore returns correct usage", function()
        CommandSage_AdaptiveLearning:IncrementUsage("/dance")
        CommandSage_AdaptiveLearning:IncrementUsage("/dance")
        assert.equals(2, CommandSage_AdaptiveLearning:GetUsageScore("/dance"))
    end)

    it("ResetUsageData clears table", function()
        CommandSage_AdaptiveLearning:IncrementUsage("/dance")
        CommandSage_AdaptiveLearning:ResetUsageData()
        assert.is_nil(_G.CommandSageDB.usageData)
    end)

    it("printing after reset doesn't error", function()
        assert.has_no.errors(function()
            CommandSage_AdaptiveLearning:ResetUsageData()
        end)
    end)

    it("handles multiple different slash commands usage", function()
        CommandSage_AdaptiveLearning:IncrementUsage("/dance")
        CommandSage_AdaptiveLearning:IncrementUsage("/macro")
        assert.equals(1, CommandSage_AdaptiveLearning:GetUsageScore("/dance"))
        assert.equals(1, CommandSage_AdaptiveLearning:GetUsageScore("/macro"))
    end)

    it("handles no CommandSageDB gracefully", function()
        _G.CommandSageDB = nil
        assert.has_no.errors(function()
            CommandSage_AdaptiveLearning:IncrementUsage("/test")
        end)
    end)

    it("does not break if usageData is partially corrupted", function()
        _G.CommandSageDB.usageData = 123  -- incorrectly set
        assert.has_no.errors(function()
            CommandSage_AdaptiveLearning:IncrementUsage("/fix")
        end)
        assert.is_table(_G.CommandSageDB.usageData)
        assert.equals(1, _G.CommandSageDB.usageData["/fix"])
    end)

    it("IncrementUsage is case-insensitive for the slash? (Should store exact or lower?)", function()
        CommandSage_AdaptiveLearning:IncrementUsage("/DANCE")
        assert.not_nil(_G.CommandSageDB.usageData["/DANCE"])
    end)
end)
