-- Modules/CommandSage_UIAccessibility.lua

-- This module provides accessibility-related functions such as toggling high contrast or large text,
-- and reading back text via TTS if available.

CommandSage_UIAccessibility = {}
-- Store state in module fields.
CommandSage_UIAccessibility.highContrast = false
CommandSage_UIAccessibility.largeText = false

--------------------------------------------------------------------------------
-- EnableHighContrast: Activates high contrast mode.
--------------------------------------------------------------------------------
function CommandSage_UIAccessibility:EnableHighContrast()
    self.highContrast = true
    print("High contrast mode enabled.")
end

--------------------------------------------------------------------------------
-- DisableHighContrast: Deactivates high contrast mode.
--------------------------------------------------------------------------------
function CommandSage_UIAccessibility:DisableHighContrast()
    self.highContrast = false
    print("High contrast mode disabled.")
end

--------------------------------------------------------------------------------
-- ToggleHighContrast: Flips the high contrast state.
--------------------------------------------------------------------------------
function CommandSage_UIAccessibility:ToggleHighContrast()
    if self.highContrast then
        self:DisableHighContrast()
    else
        self:EnableHighContrast()
    end
end

--------------------------------------------------------------------------------
-- EnableLargeText: Activates large text mode.
--------------------------------------------------------------------------------
function CommandSage_UIAccessibility:EnableLargeText()
    self.largeText = true
    print("Large text mode enabled.")
end

--------------------------------------------------------------------------------
-- DisableLargeText: Deactivates large text mode.
--------------------------------------------------------------------------------
function CommandSage_UIAccessibility:DisableLargeText()
    self.largeText = false
    print("Large text mode disabled.")
end

--------------------------------------------------------------------------------
-- ReadBack: Uses TTS to read back text if available, and always prints the text.
-- Defensive checks ensure that if no text is provided or TTS fails, no error occurs.
--------------------------------------------------------------------------------
function CommandSage_UIAccessibility:ReadBack(text)
    if not text then
        print("ReadBack: No text provided.")
        return
    end
    if C_VoiceChat and type(C_VoiceChat.SpeakText) == "function" and
            Enum and Enum.VoiceTtsDestination and Enum.VoiceTtsDestination.LocalPlayback then
        local success, err = pcall(function()
            C_VoiceChat.SpeakText(text, Enum.VoiceTtsDestination.LocalPlayback, 0, 100)
        end)
        if not success then
            print("Error in TTS SpeakText: " .. tostring(err))
        end
    end
    print(text)
end

-- (Optionally, you could also add a ToggleLargeText method if needed.)

return CommandSage_UIAccessibility
