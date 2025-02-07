-- File: Modules/CommandSage_UIAccessibility.lua
CommandSage_UIAccessibility = {}
CommandSage_UIAccessibility.highContrast = false
CommandSage_UIAccessibility.largeText = false

function CommandSage_UIAccessibility:EnableHighContrast()
    self.highContrast = true
    print("High contrast mode enabled.")
end

function CommandSage_UIAccessibility:DisableHighContrast()
    self.highContrast = false
    print("High contrast mode disabled.")
end

function CommandSage_UIAccessibility:ToggleHighContrast()
    if self.highContrast then
        self:DisableHighContrast()
    else
        self:EnableHighContrast()
    end
end

function CommandSage_UIAccessibility:EnableLargeText()
    self.largeText = true
    print("Large text mode enabled.")
end

function CommandSage_UIAccessibility:DisableLargeText()
    self.largeText = false
    print("Large text mode disabled.")
end

function CommandSage_UIAccessibility:ReadBack(text)
    if not text or text == "" then
        print("ReadBack: No text provided.")
        return
    end
    if not (C_VoiceChat and type(C_VoiceChat.SpeakText) == "function" and
            Enum and Enum.VoiceTtsDestination and Enum.VoiceTtsDestination.LocalPlayback) then
        print(text)
        return
    end
    local success, err = pcall(function()
        C_VoiceChat.SpeakText(text, Enum.VoiceTtsDestination.LocalPlayback, 0, 100)
    end)
    if not success then
        print("Error in TTS SpeakText: " .. tostring(err))
    end
    print(text)
end

return CommandSage_UIAccessibility
