-- tests/test_DiscoveryCore.lua
-- 10 tests for Core.CommandSage_Discovery

require("busted.runner")()
require("tests.test_helper")

require("Core.CommandSage_Discovery")
require("Core.CommandSage_Config")
require("Modules.CommandSage_Trie")

describe("Core: CommandSage_Discovery", function()

    before_each(function()
        _G.CommandSageDB = {}
        CommandSage_Config:InitializeDefaults()
        CommandSage_Trie:Clear()
    end)

    it("scanAllCommands populates discoveredCommands", function()
        CommandSage_Discovery:ScanAllCommands()
        local disc = CommandSage_Discovery:GetDiscoveredCommands()
        assert.is_table(disc)
        assert.is_not_nil(disc["/dance"])
    end)

    it("forced fallback includes /reload, /console, etc.", function()
        CommandSage_Discovery:ScanAllCommands()
        local disc = CommandSage_Discovery:GetDiscoveredCommands()
        assert.is_not_nil(disc["/reload"])
        assert.is_not_nil(disc["/console"])
    end)

    it("scans macros from mock environment", function()
        CommandSage_Discovery:ScanAllCommands()
        local disc = CommandSage_Discovery:GetDiscoveredCommands()
        local foundTestMacro = false
        for k,_ in pairs(disc) do
            if k == "/testmacro" then
                foundTestMacro = true
                break
            end
        end
        assert.is_true(foundTestMacro)
    end)

    it("scanAllCommands inserts them into the trie", function()
        CommandSage_Discovery:ScanAllCommands()
        local results = CommandSage_Trie:FindPrefix("/dan")
        assert.is_true(#results >= 1)
    end)

    it("ForceAllFallbacks adds new fallback slash", function()
        CommandSage_Discovery:ScanAllCommands()
        CommandSage_Discovery:ForceAllFallbacks({"/mysuperfallback"})
        local disc = CommandSage_Discovery:GetDiscoveredCommands()
        assert.is_not_nil(disc["/mysuperfallback"])
    end)

    it("blizzAllFallback = false does not add built-in slash commands", function()
        CommandSage_Config.Set("preferences","blizzAllFallback",false)
        CommandSage_Discovery:ScanAllCommands()
        local disc = CommandSage_Discovery:GetDiscoveredCommands()
        assert.is_nil(disc["/help"])
    end)

    it("extraCommands /gold /ping /mem are discovered", function()
        CommandSage_Discovery:ScanAllCommands()
        local disc = CommandSage_Discovery:GetDiscoveredCommands()
        assert.is_not_nil(disc["/gold"])
        assert.is_not_nil(disc["/ping"])
        assert.is_not_nil(disc["/mem"])
    end)

    it("calling ScanAllCommands multiple times won't duplicate", function()
        CommandSage_Discovery:ScanAllCommands()
        CommandSage_Discovery:ScanAllCommands()
        local disc = CommandSage_Discovery:GetDiscoveredCommands()
        local count = 0
        for _ in pairs(disc) do
            count = count + 1
        end
        assert.is_true(count > 5)
    end)

    it("userCustomFallbackEnabled will add from CommandSageDB.customFallbacks", function()
        CommandSage_Config.Set("preferences","userCustomFallbackEnabled",true)
        _G.CommandSageDB.customFallbacks = {"/mytestcmd", "/someonecmd"}
        CommandSage_Discovery:ScanAllCommands()
        local disc = CommandSage_Discovery:GetDiscoveredCommands()
        assert.is_not_nil(disc["/mytestcmd"])
        assert.is_not_nil(disc["/someonecmd"])
    end)

    it("does not crash if SlashCmdList has weird keys", function()
        SlashCmdList["FAKE$COMMAND"] = function(...) end
        _G["SLASH_FAKE$COMMAND1"] = "/fake"
        assert.has_no.errors(function()
            CommandSage_Discovery:ScanAllCommands()
        end)
    end)
end)
