-- =============================================================================
-- CommandSage_ConfigGUI.lua
-- A small config panel so users can toggle features without slash commands.
-- =============================================================================

CommandSage_ConfigGUI = {}

local guiFrame = nil

local function CreateCheckbox(parent, label, cvar, offsetY, tooltip)
    local cb = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
    cb.Text:SetText(label)
    cb:SetPoint("TOPLEFT", 20, offsetY)
    cb:SetScript("OnClick", function(self)
        local val = self:GetChecked() == true
        CommandSage_Config.Set("preferences", cvar, val)
        if tooltip then
            GameTooltip:Hide()
        end
    end)
    cb:SetScript("OnEnter", function(self)
        if tooltip then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(tooltip, 1, 1, 1, 1, true)
        end
    end)
    cb:SetScript("OnLeave", function(self)
        if tooltip then
            GameTooltip:Hide()
        end
    end)

    cb:SetChecked(CommandSage_Config.Get("preferences", cvar))
    return cb
end

function CommandSage_ConfigGUI:InitGUI()
    guiFrame = CreateFrame("Frame", "CommandSageConfigFrame", UIParent, "BasicFrameTemplate")
    guiFrame:SetSize(380, 460)
    guiFrame:SetPoint("CENTER")
    guiFrame:SetMovable(true)
    guiFrame:EnableMouse(true)
    guiFrame:RegisterForDrag("LeftButton")
    guiFrame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    guiFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)
    guiFrame.TitleText:SetText("CommandSage Configuration")

    local yOffset = -40
    local cb1 = CreateCheckbox(guiFrame, "Enable Animated AutoType", "animateAutoType", yOffset, "Simulates typing slash commands.")
    yOffset = yOffset - 30
    local cb2 = CreateCheckbox(guiFrame, "Advanced Styling", "advancedStyling", yOffset, "Enable fancy styling for suggestion popup.")
    yOffset = yOffset - 30
    local cb3 = CreateCheckbox(guiFrame, "Partial Fuzzy Fallback", "partialFuzzyFallback", yOffset, "When no prefix match, search entire list.")
    yOffset = yOffset - 30
    local cb4 = CreateCheckbox(guiFrame, "Shell Context Enabled", "shellContextEnabled", yOffset, "Use /cd <command> to skip slash.")
    yOffset = yOffset - 30
    local cb5 = CreateCheckbox(guiFrame, "Terminal Goodies", "enableTerminalGoodies", yOffset, "Enables 50+ terminal-like slash commands.")
    yOffset = yOffset - 30
    local cb6 = CreateCheckbox(guiFrame, "Persist Command History", "persistHistory", yOffset, "Save command usage between sessions.")
    yOffset = yOffset - 30

    local cb7 = CreateCheckbox(guiFrame, "Always Disable Hotkeys in Chat", "alwaysDisableHotkeysInChat", yOffset,
            "If checked, your normal keybinds won't fire when chat is focused.")
    yOffset = yOffset - 30

    local cb8 = CreateCheckbox(guiFrame, "Blizzard All Fallback", "blizzAllFallback", yOffset,
            "Scan all built-in slash commands by default.")
    yOffset = yOffset - 30

    local closeBtn = CreateFrame("Button", nil, guiFrame, "UIPanelButtonTemplate")
    closeBtn:SetSize(80, 22)
    closeBtn:SetPoint("BOTTOM", 0, 10)
    closeBtn:SetText("Close")
    closeBtn:SetScript("OnClick", function()
        guiFrame:Hide()
    end)

    guiFrame:Hide()
end

function CommandSage_ConfigGUI:Toggle()
    if not guiFrame then
        self:InitGUI()
    end
    if guiFrame:IsShown() then
        guiFrame:Hide()
    else
        guiFrame:Show()
    end
end

