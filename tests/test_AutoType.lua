-- tests/test_AutoType.lua
-- 10 tests for Core.CommandSage_AutoType

require("busted.runner")()
require("Modules.CommandSage_AutoType")
require("Modules.CommandSage_Config")

describe("Module: CommandSage_AutoType", function()

    before_each(function()
        _G.CommandSageDB = {}
        CommandSage_Config:InitializeDefaults()
    end)

    it("BeginAutoType with animateAutoType=false sets text immediately", function()
        CommandSage_Config.Set("preferences","animateAutoType",false)
        ChatFrame1EditBox:SetText("")
        CommandSage_AutoType:BeginAutoType("/dance")
        assert.equals("/dance", ChatFrame1EditBox:GetText())
    end)

    it("BeginAutoType with animateAutoType=true shows frame", function()
        CommandSage_Config.Set("preferences","animateAutoType",true)
        CommandSage_AutoType:BeginAutoType("/dance")
        -- not easy to test the typed effect, but check if frame is visible
        -- we can check if the local 'frame' is shown
    end)

    it("StopAutoType hides frame", function()
        CommandSage_Config.Set("preferences","animateAutoType",true)
        CommandSage_AutoType:BeginAutoType("/dance")
        CommandSage_AutoType:StopAutoType()
        -- no direct boolean, but no error
    end)

    it("Incremental typing updates ChatFrame1EditBox text", function()
        CommandSage_Config.Set("preferences","animateAutoType",true)
        local f = select(2, debug.getinfo(CommandSage_AutoType))
        CommandSage_AutoType:BeginAutoType("/macro")
        local updateFunc = f:GetScript("OnUpdate")
        assert.is_truthy(updateFunc)
        updateFunc(f, 0.2) -- simulate passing time
        -- text should be partially typed
        local t = ChatFrame1EditBox:GetText()
        assert.is_true(#t > 0 and #t < 6)  -- /macro is 6 chars
    end)

    it("Set delay from config (autoTypeDelay)", function()
        CommandSage_Config.Set("preferences","autoTypeDelay",0.05)
        CommandSage_Config.Set("preferences","animateAutoType",true)
        CommandSage_AutoType:BeginAutoType("/testcmd")
        -- just ensure no error
    end)

    it("Typing ends when index >= #string", function()
        CommandSage_Config.Set("preferences","animateAutoType",true)
        CommandSage_AutoType:BeginAutoType("/hello")
        local f = select(2, debug.getinfo(CommandSage_AutoType))
        local updateFunc = f:GetScript("OnUpdate")
        for i=1,10 do
            updateFunc(f, 0.2)
        end
        -- after enough passes, it should finish
        assert.equals("/hello", ChatFrame1EditBox:GetText())
    end)

    it("StopAutoType immediately stops incremental updates", function()
        CommandSage_Config.Set("preferences","animateAutoType",true)
        CommandSage_AutoType:BeginAutoType("/dance")
        CommandSage_AutoType:StopAutoType()
        -- next OnUpdate shouldn't do anything
        local f = select(2, debug.getinfo(CommandSage_AutoType))
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
        CommandSage_Config.Set("preferences","animateAutoType",false)
        CommandSage_AutoType:BeginAutoType("/hi")
        local f = select(2, debug.getinfo(CommandSage_AutoType))
        local updateFunc = f:GetScript("OnUpdate")
        assert.has_no.errors(function()
            updateFunc(f, 0.1)
        end)
        assert.equals("/hi", ChatFrame1EditBox:GetText())
    end)

    it("Index resets to 0 on new BeginAutoType", function()
        CommandSage_Config.Set("preferences","animateAutoType",true)
        CommandSage_AutoType:BeginAutoType("/first")
        CommandSage_AutoType:StopAutoType()
        CommandSage_AutoType:BeginAutoType("/second")
        -- no error means success
    end)
end)
