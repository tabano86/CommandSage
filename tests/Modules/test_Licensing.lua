-- tests/test_Licensing.lua
-- 10 tests for Core.CommandSage_Licensing

require("tests.test_helper")

if not SlashCmdList then
    SlashCmdList = {}
end
SlashCmdList["CMDLICENSE"] = function(msg)
    CommandSage_Licensing:HandleLicenseCommand(msg)
end

describe("Module: CommandSage_Licensing", function()

    before_each(function()
        _G.CommandSageDB = {}
        CommandSage_Config:InitializeDefaults()
    end)

    it("IsProActive returns true if monetizationEnabled=false", function()
        assert.is_true(CommandSage_Licensing:IsProActive())
    end)

    it("IsProActive false if monetizationEnabled=true and no valid key", function()
        CommandSage_Config.Set("preferences", "monetizationEnabled", true)
        assert.is_false(CommandSage_Licensing:IsProActive())
    end)

    it("HandleLicenseCommand sets licenseKey in DB", function()
        SlashCmdList["CMDLICENSE"]("MY-PRO-KEY")
        local key = _G.CommandSageDB.licenseKey
        assert.equals("MY-PRO-KEY", key)
    end)

    it("With correct key, IsProActive is true", function()
        CommandSage_Config.Set("preferences", "monetizationEnabled", true)
        CommandSage_Licensing:HandleLicenseCommand("MY-PRO-KEY")
        assert.is_true(CommandSage_Licensing:IsProActive())
    end)

    it("HandleLicenseCommand empty param prints status", function()
        assert.has_no.errors(function()
            SlashCmdList["CMDLICENSE"]("")
        end)
    end)

    it("invalid key leaves IsProActive false", function()
        CommandSage_Config.Set("preferences", "monetizationEnabled", true)
        CommandSage_Licensing:HandleLicenseCommand("WRONG-KEY")
        assert.is_false(CommandSage_Licensing:IsProActive())
    end)

    it("GetLicenseKey returns whatever is stored", function()
        _G.CommandSageDB.licenseKey = "TESTING-123"
        local val = CommandSage_Licensing:GetLicenseKey()
        assert.equals("TESTING-123", val)
    end)

    it("No error if no DB present", function()
        _G.CommandSageDB = nil
        assert.has_no.errors(function()
            CommandSage_Licensing:IsProActive()
        end)
    end)

    it("monetizationEnabled false => always pro", function()
        _G.CommandSageDB.licenseKey = "GARBAGE"
        CommandSage_Config.Set("preferences", "monetizationEnabled", false)
        assert.is_true(CommandSage_Licensing:IsProActive())
    end)

    it("HandleLicenseCommand prints if key is recognized or not", function()
        CommandSage_Config.Set("preferences", "monetizationEnabled", true)
        assert.has_no.errors(function()
            SlashCmdList["CMDLICENSE"]("RANDOM")
        end)
    end)
end)
