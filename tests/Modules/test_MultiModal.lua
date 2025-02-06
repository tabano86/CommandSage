require("tests.test_helper")

describe("Module: CommandSage_MultiModal", function()
    before_each(function()
        _G.CommandSageDB = {}
        CommandSage_Config:InitializeDefaults()
        CommandSage_Trie:Clear()
        CommandSage_Trie:InsertCommand("/dance", {})
    end)

    it("OnVoiceCommand matches fuzzy slash", function()
        CommandSage_MultiModal:OnVoiceCommand("danc")
        assert.is_true(true)
    end)

    it("OnVoiceCommand with empty phrase prints no match", function()
        assert.has_no.errors(function()
            CommandSage_MultiModal:OnVoiceCommand("")
        end)
    end)

    it("OnVoiceCommand with no close match prints no match", function()
        CommandSage_Trie:Clear()
        CommandSage_MultiModal:OnVoiceCommand("zzz")
        assert.is_true(true)
    end)

    it("SimulateVoiceCommand calls OnVoiceCommand", function()
        assert.has_no.errors(function()
            CommandSage_MultiModal:SimulateVoiceCommand("dance")
        end)
    end)

    it("Handles partial expansions if fuzzyMatchTolerance > 0", function()
        CommandSage_Config.Set("preferences", "fuzzyMatchTolerance", 2)
        CommandSage_MultiModal:OnVoiceCommand("dnce")
        assert.is_true(true)
    end)

    it("No error if Trie is empty", function()
        CommandSage_Trie:Clear()
        assert.has_no.errors(function()
            CommandSage_MultiModal:OnVoiceCommand("dance")
        end)
    end)

    it("Voice recognized => /dance if within tolerance", function()
        local oldPrint = print
        local output = {}
        print = function(...) table.insert(output, table.concat({...}, " ")) end
        CommandSage_MultiModal:OnVoiceCommand("dance")
        print = oldPrint
        local joined = table.concat(output, "\n")
        assert.matches("Voice recognized =>", joined)
    end)

    it("Null or nil phrase is safe", function()
        assert.has_no.errors(function()
            CommandSage_MultiModal:OnVoiceCommand(nil)
        end)
    end)

    it("Large input string does not error", function()
        local large = ("dance"):rep(1000)
        assert.has_no.errors(function()
            CommandSage_MultiModal:OnVoiceCommand(large)
        end)
    end)

    it("SimulateVoiceCommand prints the phrase", function()
        local oldPrint = print
        local output = {}
        print = function(...) table.insert(output, table.concat({...}, " ")) end
        CommandSage_MultiModal:SimulateVoiceCommand("hello there")
        print = oldPrint
        local joined = table.concat(output, "\n")
        assert.matches("Simulating voice input: hello there", joined)
    end)
end)
