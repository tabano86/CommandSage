-- tests/test_AutoType.lua
-- 10 tests for Modules.CommandSage_AutoType
require("busted.runner")()
require("tests.test_helper")

require("Modules.CommandSage_AutoType")
require("Core.CommandSage_Config")

describe("Module: CommandSage_AutoType", function()

    before_each(function()
        _G.CommandSageDB = {}
        CommandSage_Config:InitializeDefaults()
    end)

    it("BeginAutoType with animateAutoType=false sets text immediately", function()
        CommandSage_Config.Set("preferences", "animateAutoType", false)
        ChatFrame1EditBox:SetText("")
        CommandSage_AutoType:BeginAutoType("/dance")
        assert.equals("/dance", ChatFrame1EditBox:GetText())
    end)

    it("BeginAutoType with animateAutoType=true shows frame", function()
        CommandSage_Config.Set("preferences", "animateAutoType", true)
        assert.has_no.errors(function()
            CommandSage_AutoType:BeginAutoType("/dance")
        end)
    end)

    it("StopAutoType hides frame", function()
        CommandSage_Config.Set("preferences", "animateAutoType", true)
        CommandSage_AutoType:BeginAutoType("/dance")
        CommandSage_AutoType:StopAutoType()
        -- no error
    end)

    it("Incremental typing updates ChatFrame1EditBox text", function()
        CommandSage_Config.Set("preferences", "animateAutoType", true)
        -- Use the frame directly (avoid debug.getinfo)
        local f = CommandSage_AutoType.frame
        CommandSage_AutoType:BeginAutoType("/macro")
        local updateFunc = f:GetScript("OnUpdate")
        assert.is_truthy(updateFunc)
        updateFunc(f, 0.2) -- simulate time
        local t = ChatFrame1EditBox:GetText()
        assert.is_true(#t > 0 and #t < #"/macro")
    end)

    it("Set delay from config (autoTypeDelay)", function()
        CommandSage_Config.Set("preferences", "autoTypeDelay", 0.05)
        CommandSage_Config.Set("preferences", "animateAutoType", true)
        assert.has_no.errors(function()
            CommandSage_AutoType:BeginAutoType("/testcmd")
        end)
    end)

    it("Typing ends when index >= #string", function()
        CommandSage_Config.Set("preferences", "animateAutoType", true)
        CommandSage_AutoType:BeginAutoType("/hello")
        local f = CommandSage_AutoType.frame
        local updateFunc = f:GetScript("OnUpdate")
        for i = 1, 10 do
            updateFunc(f, 0.2)
        end
        assert.equals("/hello", ChatFrame1EditBox:GetText())
    end)

    it("StopAutoType immediately stops incremental updates", function()
        CommandSage_Config.Set("preferences", "animateAutoType", true)
        CommandSage_AutoType:BeginAutoType("/dance")
        CommandSage_AutoType:StopAutoType()
        local f = CommandSage_AutoType.frame
        local updateFunc = f:GetScript("OnUpdate")
        updateFunc(f, 0.2)
        assert.equals("", ChatFrame1EditBox:GetText())
    end)

    it("No error if BeginAutoType called repeatedly", function()
        assert.has_no.errors(function()
            CommandSage_AutoType:BeginAutoType("/a")
            CommandSage_AutoType:BeginAutoType("/b")
        end)
    end)

    it("If animateAutoType=false, OnUpdate does nothing", function()
        CommandSage_Config.Set("preferences", "animateAutoType", false)
        CommandSage_AutoType:BeginAutoType("/hi")
        local f = CommandSage_AutoType.frame
        local updateFunc = f:GetScript("OnUpdate")
        assert.has_no.errors(function()
            updateFunc(f, 0.1)
        end)
        assert.equals("/hi", ChatFrame1EditBox:GetText())
    end)

    it("Index resets to 0 on new BeginAutoType", function()
        CommandSage_Config.Set("preferences", "animateAutoType", true)
        CommandSage_AutoType:BeginAutoType("/first")
        CommandSage_AutoType:StopAutoType()
        assert.has_no.errors(function()
            CommandSage_AutoType:BeginAutoType("/second")
        end)
    end)
end)
