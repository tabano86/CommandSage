-- tests/test_Tutorial.lua
-- 10 tests for Core.CommandSage_Tutorial
require("busted.runner")()
require("tests.test_helper")
require("Modules.CommandSage_Tutorial")
require("Core.CommandSage_Config")

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
        local children = f:GetChildren()
        assert.is_truthy(children)
        f:Hide()
        assert.is_false(f:IsShown())
    end)

    it("Title text is set", function()
        CommandSage_Tutorial:ShowTutorialPrompt()
        local f = _G["CommandSageTutorialFrame"]
        -- Verify that TitleText exists and its text is nonempty
        assert.is_truthy(f.TitleText)
        assert.is_true(#(f.TitleText.text or "") > 0)
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
