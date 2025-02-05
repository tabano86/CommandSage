require("busted.runner")()
require("Modules/CommandSage_AdaptiveLearning")
require("Modules/CommandSage_Config")

describe("CommandSage_AdaptiveLearning", function()
    before_each(function()
        _G.CommandSageDB = {}
        CommandSage_Config:InitializeDefaults()
    end)

    it("starts with no usage data", function()
        assert.is_nil(CommandSageDB.usageData)
    end)

    it("increments usage", function()
        CommandSage_AdaptiveLearning:IncrementUsage("/dance")
        assert.same(1, CommandSageDB.usageData["/dance"])
    end)

    it("gets usage score properly", function()
        CommandSage_AdaptiveLearning:IncrementUsage("/dance")
        local score = CommandSage_AdaptiveLearning:GetUsageScore("/dance")
        assert.equals(1, score)
    end)

    it("resets usage data", function()
        CommandSage_AdaptiveLearning:IncrementUsage("/dance")
        CommandSage_AdaptiveLearning:ResetUsageData()
        assert.is_nil(CommandSageDB.usageData)
    end)

    it("handles multiple increments", function()
        CommandSage_AdaptiveLearning:IncrementUsage("/dance")
        CommandSage_AdaptiveLearning:IncrementUsage("/dance")
        assert.equals(2, CommandSage_AdaptiveLearning:GetUsageScore("/dance"))
    end)

    it("usage score for unknown is 0", function()
        local s = CommandSage_AdaptiveLearning:GetUsageScore("/unknown")
        assert.equals(0, s)
    end)

    it("does not crash if DB missing", function()
        _G.CommandSageDB = nil
        assert.has_no.errors(function()
            CommandSage_AdaptiveLearning:IncrementUsage("/anything")
        end)
    end)

    it("increment usage multiple commands", function()
        CommandSage_AdaptiveLearning:IncrementUsage("/dance")
        CommandSage_AdaptiveLearning:IncrementUsage("/macro")
        assert.equals(1, CommandSage_AdaptiveLearning:GetUsageScore("/dance"))
        assert.equals(1, CommandSage_AdaptiveLearning:GetUsageScore("/macro"))
    end)

    it("reset prints message", function()
        -- Just check it doesn't error
        assert.has_no.errors(function()
            CommandSage_AdaptiveLearning:ResetUsageData()
        end)
    end)

    it("get usage after reset is 0", function()
        CommandSage_AdaptiveLearning:IncrementUsage("/dance")
        CommandSage_AdaptiveLearning:ResetUsageData()
        local s = CommandSage_AdaptiveLearning:GetUsageScore("/dance")
        assert.equals(0, s)
    end)
end)
