-- =============================================================================
-- CommandSage_UIAccessibility.lua
-- Accessibility features like high-contrast mode, large text, TTS readback
-- =============================================================================

CommandSage_UIAccessibility = {}

local highContrast = false
local largeText = false

function CommandSage_UIAccessibility:EnableHighContrast()
    highContrast = true
    -- Possibly restyle frames, change background color, etc.
end

function CommandSage_UIAccessibility:DisableHighContrast()
    highContrast = false
    -- revert
end

function CommandSage_UIAccessibility:EnableLargeText()
    largeText = true
    -- Increase font sizes in suggestion frames
end

function CommandSage_UIAccessibility:DisableLargeText()
    largeText = false
    -- revert
end

function CommandSage_UIAccessibility:ReadBack(text)
    -- If TTS is supported in Classic, or if user has a TTS plugin,
    -- we might do something like:
    if C_VoiceChat and C_VoiceChat.SpeakText then
        C_VoiceChat.SpeakText(text, Enum.VoiceTtsDestination.LocalPlayback, 0, 100)
    else
        print("(TTS not available) " .. text)
    end
end
