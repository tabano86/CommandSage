--==========================
-- tests/Core/test_CoreMain.lua
--==========================
-- Exactly the same content you already had, but placed in tests/Core/

require("tests.test_helper")

describe("Core: CommandSage_Core", function()

    before_each(function()
        _G.CommandSageDB = {}
        CommandSage_Config:InitializeDefaults()
    end)

    it("initial ADDON_LOADED triggers config init", function()
        local loadedCount = 0
        local oldInit = CommandSage_Config.InitializeDefaults
        CommandSage_Config.InitializeDefaults = function(...)
            loadedCount = loadedCount + 1
            return oldInit(...)
        end

        local frame = CommandSage.frame
        local eventFunc = frame:GetScript("OnEvent")
        eventFunc(frame, "ADDON_LOADED", "CommandSage")

        assert.equals(1, loadedCount)
        CommandSage_Config.InitializeDefaults = oldInit
    end)

    it("PLAYER_LOGIN event shows tutorial if enabled", function()
        local oldFunc = CommandSage_Tutorial.ShowTutorialPrompt
        local triggered = false
        CommandSage_Tutorial.ShowTutorialPrompt = function(...)
            triggered = true
        end

        local frame = CommandSage.frame
        local eventFunc = frame:GetScript("OnEvent")
        eventFunc(frame, "PLAYER_LOGIN")

        assert.is_true(triggered)
        CommandSage_Tutorial.ShowTutorialPrompt = oldFunc
    end)

    it("Slash command /cmdsage config <key> <value> sets preference", function()
        -- Simulate calling the slash command function
        SlashCmdList["COMMANDSAGE"]("config uiScale 1.5")
        local newVal = CommandSage_Config.Get("preferences", "uiScale")
        assert.equals(1.5, newVal)
    end)

    it("Slash command /cmdsage resetprefs resets to default", function()
        CommandSage_Config.Set("preferences", "uiTheme", "light")
        SlashCmdList["COMMANDSAGE"]("resetprefs")
        local val = CommandSage_Config.Get("preferences", "uiTheme")
        assert.equals("dark", val)
    end)

    it("Registers slash commands properly", function()
        assert.is_string(_G["SLASH_COMMANDSAGE1"])
        assert.is_function(SlashCmdList["COMMANDSAGE"])
    end)

    it("HookAllChatFrames does not error with mock frames", function()
        assert.has_no.errors(function()
            CommandSage:HookAllChatFrames()
        end)
    end)

    it("HookChatFrameEditBox sets CommandSageHooked = true", function()
        local mockEdit = CreateFrame("Frame", "MockEditBox")
        CommandSage:HookChatFrameEditBox(mockEdit)
        assert.is_true(mockEdit.CommandSageHooked)
    end)

    it("Disables keybindings if overrideHotkeysWhileTyping is true", function()
        CommandSage_Config.Set("preferences", "overrideHotkeysWhileTyping", true)
        local mockEdit = CreateFrame("Frame", "MockEditBox2")
        CommandSage:HookChatFrameEditBox(mockEdit)
        local focusFunc = mockEdit:GetScript("OnEditFocusGained")
        assert.has_no.errors(function()
            focusFunc(mockEdit)
        end)
    end)

    it("PLAYER_LOGIN event does not show tutorial if showTutorialOnStartup = false", function()
        CommandSage_Config.Set("preferences", "showTutorialOnStartup", false)
        local oldFunc = CommandSage_Tutorial.ShowTutorialPrompt
        local wasTriggered = false
        CommandSage_Tutorial.ShowTutorialPrompt = function()
            wasTriggered = true
        end

        local frame = CommandSage.frame
        local eventFunc = frame:GetScript("OnEvent")
        eventFunc(frame, "PLAYER_LOGIN")

        assert.is_false(wasTriggered)
        CommandSage_Tutorial.ShowTutorialPrompt = oldFunc
    end)

    it("ADDON_UNLOADED event clears shell context if same addon name", function()
        CommandSage_ShellContext:HandleCd("macro")
        assert.equals("macro", CommandSage_ShellContext:GetCurrentContext())
        local frame = CommandSage.frame
        local eventFunc = frame:GetScript("OnEvent")
        eventFunc(frame, "ADDON_UNLOADED", "CommandSage")
        assert.is_nil(CommandSage_ShellContext:GetCurrentContext())
    end)
end)
