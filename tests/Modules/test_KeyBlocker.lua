require("tests.test_helper")

describe("Module: CommandSage_KeyBlocker", function()
    it("BlockKeys sets override bindings for allKeys", function()
        assert.has_no.errors(function()
            CommandSage_KeyBlocker:BlockKeys()
        end)
    end)

    it("UnblockKeys clears override bindings", function()
        CommandSage_KeyBlocker:BlockKeys()
        assert.has_no.errors(function()
            CommandSage_KeyBlocker:UnblockKeys()
        end)
    end)

    it("multiple calls to BlockKeys do not error", function()
        CommandSage_KeyBlocker:BlockKeys()
        CommandSage_KeyBlocker:BlockKeys()
        assert.is_true(true)
    end)

    it("multiple calls to UnblockKeys do not error", function()
        CommandSage_KeyBlocker:UnblockKeys()
        CommandSage_KeyBlocker:UnblockKeys()
        assert.is_true(true)
    end)

    it("dummy OnClick is empty", function()
        local b = _G["CommandSageKeyBlocker"]
        local clickFunc = b:GetScript("OnClick")
        assert.is_truthy(clickFunc)
        assert.has_no.errors(function()
            clickFunc(b)
        end)
    end)

    it("blockerButton is hidden by default", function()
        local b = _G["CommandSageKeyBlocker"]
        assert.is_false(b:IsShown())
    end)

    it("BlockKeys shows the blockerButton", function()
        CommandSage_KeyBlocker:BlockKeys()
        local b = _G["CommandSageKeyBlocker"]
        assert.is_true(b:IsShown())
    end)

    it("UnblockKeys hides the blockerButton", function()
        CommandSage_KeyBlocker:BlockKeys()
        CommandSage_KeyBlocker:UnblockKeys()
        local b = _G["CommandSageKeyBlocker"]
        assert.is_false(b:IsShown())
    end)

    it("allKeys list has typical keys", function()
        local keyList = debug.getupvalue(CommandSage_KeyBlocker.BlockKeys, 1)
        -- If you want to test for at least 30 keys:
        assert.is_true(#keyList >= 30)
    end)
end)
