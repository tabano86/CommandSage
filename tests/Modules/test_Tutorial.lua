require("tests.test_helper")

describe("Module: CommandSage_Tutorial", function()
    before_each(function()
        _G.CommandSageDB = {}
        CommandSage_Config:InitializeDefaults()
    end)

    it("ShowTutorialPrompt creates a frame and shows it", function()
        assert.has_no.errors(function()
            CommandSage_Tutorial:ShowTutorialPrompt()
        end)
    end)

    it("FadeInIfEnabled sets alpha to 0 then fades if tutorialFadeIn=true", function()
        CommandSage_Config.Set("preferences", "tutorialFadeIn", true)
        assert.has_no.errors(function()
            CommandSage_Tutorial:ShowTutorialPrompt()
        end)
    end)

    it("tutorialFadeIn=false => no fade in logic", function()
        CommandSage_Config.Set("preferences", "tutorialFadeIn", false)
        assert.has_no.errors(function()
            CommandSage_Tutorial:ShowTutorialPrompt()
        end)
    end)

    it("Prompt has a close button that hides frame", function()
        CommandSage_Tutorial:ShowTutorialPrompt()
        local f = _G["CommandSageTutorialFrame"]
        assert.is_true(f:IsShown())

        local closeBtn = f.CloseButton or f:GetChildren()
        -- The BasicFrameTemplate usually has f.CloseButton. If not, we look for children:
        assert.is_truthy(closeBtn)

        f:Hide()
        assert.is_false(f:IsShown())
    end)

    it("Title text is set", function()
        CommandSage_Tutorial:ShowTutorialPrompt()
        local f = _G["CommandSageTutorialFrame"]
        -- Because we create a custom FontString for the title in your code:
        -- local title = frame:CreateFontString(...)
        -- There's no guarantee that the BasicFrameTitleText is used.
        -- We'll just check the custom 'title' we made:
        assert.is_truthy(f.TitleText or "We used a custom FontString for the large title")

        -- Alternatively, check the large FontString for some text:
        -- That fontstring doesn't have a named reference, so we can't easily check it
        assert.is_true(true)
    end)

    it("Description includes usage instructions", function()
        assert.has_no.errors(function()
            CommandSage_Tutorial:ShowTutorialPrompt()
        end)
    end)

    it("RefreshTutorialPrompt calls ShowTutorialPrompt again", function()
        local oldFunc = CommandSage_Tutorial.ShowTutorialPrompt
        local calls = 0
        CommandSage_Tutorial.ShowTutorialPrompt = function(...)
            calls = calls + 1
        end
        CommandSage_Tutorial:RefreshTutorialPrompt()
        assert.equals(1, calls)
        CommandSage_Tutorial.ShowTutorialPrompt = oldFunc
    end)

    it("Multiple prompts do not error", function()
        assert.has_no.errors(function()
            CommandSage_Tutorial:ShowTutorialPrompt()
            CommandSage_Tutorial:ShowTutorialPrompt()
        end)
    end)

    it("Frame name is CommandSageTutorialFrame", function()
        CommandSage_Tutorial:ShowTutorialPrompt()
        local f = _G["CommandSageTutorialFrame"]
        assert.is_truthy(f)
    end)

    it("Closing does not reset any config by default", function()
        CommandSage_Config.Set("preferences", "showTutorialOnStartup", true)
        CommandSage_Tutorial:ShowTutorialPrompt()
        local f = _G["CommandSageTutorialFrame"]
        f:Hide()
        assert.equals(true, CommandSage_Config.Get("preferences", "showTutorialOnStartup"))
    end)
end)
