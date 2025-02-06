-- Modules/CommandSage_UIAccessibility.lua
CommandSage_UIAccessibility = {}
local highContrast = false
local largeText = false

function CommandSage_UIAccessibility:EnableHighContrast()
    highContrast = true
    print("High contrast mode enabled.")
end

function CommandSage_UIAccessibility:DisableHighContrast()
    highContrast = false
    print("High contrast mode disabled.")
end

function CommandSage_UIAccessibility:EnableLargeText()
    largeText = true
    print("Large text mode enabled.")
end

function CommandSage_UIAccessibility:DisableLargeText()
    largeText = false
    print("Large text mode disabled.")
end

function CommandSage_UIAccessibility:ReadBack(text)
    if C_VoiceChat and C_VoiceChat.SpeakText then
        C_VoiceChat.SpeakText(text, Enum.VoiceTtsDestination.LocalPlayback, 0, 100)
    else
        -- single string
        print(text)
    end
end

function CommandSage_UIAccessibility:ToggleHighContrast()
    if highContrast then
        self:DisableHighContrast()
    else
        self:EnableHighContrast()
    end
end
