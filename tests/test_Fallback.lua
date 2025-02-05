-- tests/test_Fallback.lua
-- 10 tests for Modules.CommandSage_Fallback

require("busted.runner")()
require("tests.test_helper")

require("Modules.CommandSage_Fallback")

describe("Module: CommandSage_Fallback", function()

    before_each(function()
        CommandSage_Fallback:DisableFallback()
    end)

    it("EnableFallback sets fallbackActive=true", function()
        CommandSage_Fallback:EnableFallback()
        assert.is_true(CommandSage_Fallback:IsFallbackActive())
    end)

    it("DisableFallback sets fallbackActive=false", function()
        CommandSage_Fallback:EnableFallback()
        CommandSage_Fallback:DisableFallback()
        assert.is_false(CommandSage_Fallback:IsFallbackActive())
    end)

    it("ToggleFallback flips the state", function()
        CommandSage_Fallback:ToggleFallback()
        assert.is_true(CommandSage_Fallback:IsFallbackActive())
        CommandSage_Fallback:ToggleFallback()
        assert.is_false(CommandSage_Fallback:IsFallbackActive())
    end)

    it("IsFallbackActive returns a boolean", function()
        assert.is_false(CommandSage_Fallback:IsFallbackActive())
        CommandSage_Fallback:EnableFallback()
        assert.is_true(CommandSage_Fallback:IsFallbackActive())
    end)

    it("multiple EnableFallback calls remain true", function()
        CommandSage_Fallback:EnableFallback()
        CommandSage_Fallback:EnableFallback()
        assert.is_true(CommandSage_Fallback:IsFallbackActive())
    end)

    it("multiple DisableFallback calls remain false", function()
        CommandSage_Fallback:DisableFallback()
        CommandSage_Fallback:DisableFallback()
        assert.is_false(CommandSage_Fallback:IsFallbackActive())
    end)

    it("ToggleFallback from false => true => false => true, etc.", function()
        CommandSage_Fallback:ToggleFallback()
        local s1 = CommandSage_Fallback:IsFallbackActive()
        CommandSage_Fallback:ToggleFallback()
        local s2 = CommandSage_Fallback:IsFallbackActive()
        assert.is_not_equal(s1, s2)
    end)

    it("We can check final state after multiple toggles", function()
        CommandSage_Fallback:DisableFallback()
        CommandSage_Fallback:ToggleFallback() -- now true
        CommandSage_Fallback:ToggleFallback() -- now false
        assert.is_false(CommandSage_Fallback:IsFallbackActive())
    end)

    it("No errors if used with no config or DB", function()
        _G.CommandSageDB = nil
        assert.has_no.errors(function()
            CommandSage_Fallback:EnableFallback()
        end)
    end)

    it("No advanced interactions besides set/get fallbackActive", function()
        CommandSage_Fallback:EnableFallback()
        CommandSage_Fallback:DisableFallback()
        assert.is_false(CommandSage_Fallback:IsFallbackActive())
    end)
end)
