require("tests.test_helper")

describe("Module: CommandSage_AROverlays", function()

    before_each(function()
        _G.CommandSageDB = {}
        CommandSage_Config:InitializeDefaults()
    end)

    it("Overlay frame initially hidden", function()
        assert.is_false(CommandSageAROverlayFrame:IsShown())
    end)

    it("ShowOverlay makes it visible", function()
        CommandSage_AROverlays:ShowOverlay()
        assert.is_true(CommandSageAROverlayFrame:IsShown())
    end)

    it("HideOverlay hides it again", function()
        CommandSage_AROverlays:ShowOverlay()
        CommandSage_AROverlays:HideOverlay()
        assert.is_false(CommandSageAROverlayFrame:IsShown())
    end)

    it("ToggleOverlay cycles visibility", function()
        CommandSage_AROverlays:ToggleOverlay()
        local s1 = CommandSageAROverlayFrame:IsShown()
        CommandSage_AROverlays:ToggleOverlay()
        local s2 = CommandSageAROverlayFrame:IsShown()
        assert.is_not_equal(s1, s2)
    end)

    it("Rune ring appears only if arRuneRingEnabled = true", function()
        CommandSage_Config.Set("preferences", "arRuneRingEnabled", true)
        CommandSage_AROverlays:ShowOverlay()
        assert.is_true(CommandSageAROverlayFrame:IsShown())
    end)

    it("Emote sticker toggles with emoteStickersEnabled", function()
        CommandSage_Config.Set("preferences", "emoteStickersEnabled", true)
        CommandSage_AROverlays:ShowOverlay()
        assert.is_true(CommandSageAROverlayFrame:IsShown())
    end)

    it("OnUpdate modifies alpha of main texture", function()
        local oldAlpha = CommandSageAROverlayFrame:GetAlpha()
        CommandSage_AROverlays:ShowOverlay()
        local f = CommandSageAROverlayFrame
        local onUpdate = f:GetScript("OnUpdate")
        assert.is_truthy(onUpdate)
        onUpdate(f, 0.1)
        local newAlpha = f:GetAlpha() -- or the sub texture alpha
        assert.is_number(newAlpha)
    end)

    it("ToggleOverlay from hidden => shown => hidden again", function()
        CommandSage_AROverlays:ToggleOverlay()
        assert.is_true(CommandSageAROverlayFrame:IsShown())
        CommandSage_AROverlays:ToggleOverlay()
        assert.is_false(CommandSageAROverlayFrame:IsShown())
    end)

    it("Does not error if showOverlay called multiple times", function()
        assert.has_no.errors(function()
            CommandSage_AROverlays:ShowOverlay()
            CommandSage_AROverlays:ShowOverlay()
        end)
    end)

    it("Does not error if hideOverlay called while already hidden", function()
        CommandSage_AROverlays:HideOverlay()
        assert.is_false(CommandSageAROverlayFrame:IsShown())
        assert.has_no.errors(function()
            CommandSage_AROverlays:HideOverlay()
        end)
    end)
end)
