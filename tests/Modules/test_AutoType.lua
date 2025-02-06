-- tests/Modules/test_AutoType.lua
require("tests.test_helper")
local CommandSage_Config = require("CommandSage_Config")
local CommandSage_AutoType = require("CommandSage_AutoType")

describe("Module: CommandSage_AutoType", function()
    before_each(function()
        _G.CommandSageDB = {}
        CommandSage_Config:InitializeDefaults()

        -- Stub for ChatFrame1EditBox.
        ChatFrame1EditBox = {
            text = "",
            SetText = function(self, t)
                self.text = t
            end,
            GetText = function(self)
                return self.text
            end,
        }

        -- Create a fake frame to simulate UI behavior.
        CommandSage_AutoType.frame = {
            visible = false,
            Show = function(self)
                self.visible = true
            end,
            Hide = function(self)
                self.visible = false
            end,
            script = {},
            SetScript = function(self, event, func)
                self.script[event] = func
            end,
            GetScript = function(self, event)
                return self.script[event]
            end,
        }
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
        assert.is_truthy(CommandSage_AutoType.frame.visible)
    end)

    it("StopAutoType hides frame", function()
        CommandSage_Config.Set("preferences", "animateAutoType", true)
        CommandSage_AutoType:BeginAutoType("/dance")
        CommandSage_AutoType:StopAutoType()
        assert.is_false(CommandSage_AutoType.frame.visible)
    end)

    it("Incremental typing updates ChatFrame1EditBox text", function()
        CommandSage_Config.Set("preferences", "animateAutoType", true)
        local f = CommandSage_AutoType.frame
        CommandSage_AutoType:BeginAutoType("/macro")
        local updateFunc = f:GetScript("OnUpdate")
        assert.is_truthy(updateFunc)
        updateFunc(f, 0.2)
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
        if updateFunc then
            updateFunc(f, 0.2)
        end
        -- Since auto-type was stopped, no text updates should occur.
        assert.equals("", ChatFrame1EditBox:GetText())
    end)

    it("No error if BeginAutoType called repeatedly", function()
        assert.has_no.errors(function()
            CommandSage_AutoType:BeginAutoType("/a")
            CommandSage_AutoType:BeginAutoType("/b")
        end)
        -- When not animated, the latter command should immediately set text.
        if not CommandSage_Config.Get("preferences", "animateAutoType") then
            assert.equals("/b", ChatFrame1EditBox:GetText())
        end
    end)

    it("If animateAutoType=false, OnUpdate does nothing", function()
        CommandSage_Config.Set("preferences", "animateAutoType", false)
        CommandSage_AutoType:BeginAutoType("/hi")
        local f = CommandSage_AutoType.frame
        local updateFunc = f:GetScript("OnUpdate")
        assert.has_no.errors(function()
            if updateFunc then
                updateFunc(f, 0.1)
            end
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
        local f = CommandSage_AutoType.frame
        local updateFunc = f:GetScript("OnUpdate")
        updateFunc(f, 0.2)
        local t = ChatFrame1EditBox:GetText()
        assert.is_true(#t > 0 and #t < #"/second")
    end)

    it("Re-typing after StopAutoType resets properly", function()
        -- Set animate on
        CommandSage_Config.Set("preferences", "animateAutoType", true)

        -- Start first auto-type
        CommandSage_AutoType:BeginAutoType("/hello1")
        local f = CommandSage_AutoType.frame
        local updateFunc = f:GetScript("OnUpdate")
        -- Simulate half a second total => enough to type maybe 5 chars with default 0.1 delay
        for i = 1, 5 do
            updateFunc(f, 0.1)
        end
        -- We'll forcibly stop
        CommandSage_AutoType:StopAutoType()

        -- Now do a new auto-type
        ChatFrame1EditBox:SetText("")
        CommandSage_AutoType:BeginAutoType("/hello2")
        for i = 1, 3 do
            updateFunc(f, 0.1)
        end
        local partial = ChatFrame1EditBox:GetText()
        assert.matches("^/he", partial)
    end)
end)
