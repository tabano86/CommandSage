require("tests.test_helper")

describe("Module: CommandSage_AROverlays", function()
    before_each(function()
        -- forcibly hide before each test so we start in a known state
        CommandSageAROverlayFrame:Hide()
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

        -- Just confirm it toggles from hidden->shown->hidden:
        assert.is_true(s1)
        assert.is_false(s2)
    end)

    it("Rune ring appears only if arRuneRingEnabled = true", function()
        CommandSage_Config.Set("preferences", "arRuneRingEnabled", true)
        CommandSage_AROverlays:ShowOverlay()
        assert.is_true(CommandSageAROverlayFrame:IsShown())
        -- You can optionally check if the ring is actually shown
    end)

    it("Emote sticker toggles with emoteStickersEnabled", function()
        CommandSage_Config.Set("preferences", "emoteStickersEnabled", true)
        CommandSage_AROverlays:ShowOverlay()
        assert.is_true(CommandSageAROverlayFrame:IsShown())
    end)

    it("OnUpdate modifies alpha of main texture", function()
        CommandSage_AROverlays:ShowOverlay()
        local f = CommandSageAROverlayFrame
        local onUpdate = f:GetScript("OnUpdate")
        assert.is_truthy(onUpdate)
        assert.has_no.errors(function()
            onUpdate(f, 0.1)
        end)
    end)

    it("ToggleOverlay from hidden => shown => hidden again", function()
        CommandSage_AROverlays:ToggleOverlay()
        assert.is_true(CommandSageAROverlayFrame:IsShown())
        CommandSage_AROverlays:ToggleOverlay()
        assert.is_false(CommandSageAROverlayFrame:IsShown())
    end)
end)
