-- tests/test_UIAccessibility.lua
-- 10 tests for Modules/CommandSage_UIAccessibility.lua

require("busted.runner")()
require("Modules/CommandSage_UIAccessibility")

describe("Module: CommandSage_UIAccessibility", function()

    it("EnableHighContrast prints a message", function()
        assert.has_no.errors(function()
            CommandSage_UIAccessibility:EnableHighContrast()
        end)
    end)

    it("DisableHighContrast toggles it off", function()
        CommandSage_UIAccessibility:EnableHighContrast()
        CommandSage_UIAccessibility:DisableHighContrast()
        -- no direct check but no error
    end)

    it("EnableLargeText prints a message", function()
        assert.has_no.errors(function()
            CommandSage_UIAccessibility:EnableLargeText()
        end)
    end)

    it("DisableLargeText toggles it off", function()
        CommandSage_UIAccessibility:EnableLargeText()
        CommandSage_UIAccessibility:DisableLargeText()
        -- no error
    end)

    it("ToggleHighContrast flips the state", function()
        CommandSage_UIAccessibility:ToggleHighContrast()
        CommandSage_UIAccessibility:ToggleHighContrast()
        -- no direct check but no error
    end)

    it("ReadBack prints text if TTS not available", function()
        local oldPrint = print
        local output = {}
        print = function(...) table.insert(output, table.concat({...}," ")) end

        CommandSage_UIAccessibility:ReadBack("Hello test")

        print = oldPrint
        local joined = table.concat(output,"\n")
        assert.matches("Hello test", joined)
    end)

    it("no error if TTS is available but arguments are empty", function()
        _G.C_VoiceChat = { SpeakText = function(...) end }
        _G.Enum = { VoiceTtsDestination = { LocalPlayback=0 } }
        assert.has_no.errors(function()
            CommandSage_UIAccessibility:ReadBack("")
        end)
        _G.C_VoiceChat = nil
        _G.Enum = nil
    end)

    it("multiple toggles do not break the internal state", function()
        CommandSage_UIAccessibility:ToggleHighContrast()
        CommandSage_UIAccessibility:ToggleHighContrast()
        -- no error
    end)

    it("EnableLargeText and then readBack is valid usage scenario", function()
        CommandSage_UIAccessibility:EnableLargeText()
        assert.has_no.errors(function()
            CommandSage_UIAccessibility:ReadBack("Testing with large text mode.")
        end)
    end)

    it("DisableLargeText afterwards is also safe", function()
        CommandSage_UIAccessibility:DisableLargeText()
        -- no error
    end)
end)
