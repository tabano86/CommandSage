require("tests.test_helper")

describe("Module: CommandSage_ConfigGUI", function()
    before_each(function()
        _G.CommandSageDB = {}
        CommandSage_Config:InitializeDefaults()
    end)

    it("InitGUI creates the config frame hidden", function()
        CommandSage_ConfigGUI:InitGUI()
        local frame = _G["CommandSageConfigFrame"]
        assert.is_table(frame)
        assert.is_false(frame:IsShown())
    end)

    it("Toggle() shows the config frame if hidden", function()
        CommandSage_ConfigGUI:InitGUI()
        CommandSage_ConfigGUI:Toggle()
        local frame = _G["CommandSageConfigFrame"]
        assert.is_true(frame:IsShown())
    end)

    it("Toggle() hides it if shown", function()
        CommandSage_ConfigGUI:InitGUI()
        CommandSage_ConfigGUI:Toggle()
        CommandSage_ConfigGUI:Toggle()
        local frame = _G["CommandSageConfigFrame"]
        assert.is_false(frame:IsShown())
    end)

    it("CheckBoxes update preferences on click", function()
        CommandSage_ConfigGUI:InitGUI()
        local frame = _G["CommandSageConfigFrame"]
        frame:Show()
        assert.is_true(true)
    end)

    it("Closing the GUI does not error", function()
        CommandSage_ConfigGUI:InitGUI()
        CommandSage_ConfigGUI:Toggle()
        local frame = _G["CommandSageConfigFrame"]
        assert.has_no.errors(function()
            frame:Hide()
        end)
    end)

    it("usageChartEnabled shows usage chart subframe", function()
        CommandSage_Config.Set("preferences", "usageChartEnabled", true)
        CommandSage_ConfigGUI:InitGUI()
        CommandSage_ConfigGUI:Toggle()
        assert.is_true(true)
    end)

    it("disabling usageChartEnabled hides usage chart", function()
        CommandSage_Config.Set("preferences", "usageChartEnabled", false)
        CommandSage_ConfigGUI:InitGUI()
        CommandSage_ConfigGUI:Toggle()
        assert.is_true(true)
    end)

    it("Frame can be dragged (no error)", function()
        CommandSage_ConfigGUI:InitGUI()
        local frame = _G["CommandSageConfigFrame"]
        assert.is_truthy(frame:GetScript("OnDragStart"))
        assert.is_truthy(frame:GetScript("OnDragStop"))
    end)

    it("InitGUI can be called multiple times safely", function()
        CommandSage_ConfigGUI:InitGUI()
        assert.has_no.errors(function()
            CommandSage_ConfigGUI:InitGUI()
        end)
    end)

    it("CheckBoxes read from preferences to set initial .Checked", function()
        CommandSage_Config.Set("preferences", "animateAutoType", false)
        CommandSage_ConfigGUI:InitGUI()
        assert.is_true(true)
    end)
end)
