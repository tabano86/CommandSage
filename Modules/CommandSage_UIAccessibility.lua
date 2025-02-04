-- =============================================================================
-- CommandSage_UIAccessibility.lua
-- Accessibility features like high-contrast mode, large text, TTS readback
-- =============================================================================

CommandSage_UIAccessibility = {}

local highContrast = false
local largeText = false

function CommandSage_UIAccessibility:EnableHighContrast()
    highContrast = true
    -- Possibly restyle frames, etc.
end

function CommandSage_UIAccessibility:DisableHighContrast()
    highContrast = false
end

function CommandSage_UIAccessibility:EnableLargeText()
    largeText = true
end

function CommandSage_UIAccessibility:DisableLargeText()
    largeText = false
end

function CommandSage_UIAccessibility:ReadBack(text)
    if C_VoiceChat and C_VoiceChat.SpeakText then
        C_VoiceChat.SpeakText(text, Enum.VoiceTtsDestination.LocalPlayback, 0, 100)
    else
        print("(TTS not available) " .. text)
    end
end
