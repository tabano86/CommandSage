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

    -- set initial state from config
    cb:SetChecked(CommandSage_Config.Get("preferences", cvar))
    return cb
end

function CommandSage_ConfigGUI:InitGUI()
    guiFrame = CreateFrame("Frame", "CommandSageConfigFrame", UIParent, "BasicFrameTemplate")
    guiFrame:SetSize(380, 400)
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
    local cb1 = CreateCheckbox(guiFrame, "Enable Animated AutoType", "animateAutoType", yOffset, "If enabled, simulates typing slash commands letter by letter.")
    yOffset = yOffset - 30
    local cb2 = CreateCheckbox(guiFrame, "Advanced Styling", "advancedStyling", yOffset, "If disabled, uses simpler frames for the suggestions popup.")
    yOffset = yOffset - 30
    local cb3 = CreateCheckbox(guiFrame, "Partial Fuzzy Fallback", "partialFuzzyFallback", yOffset, "When prefix fails, search entire command list in fuzzy mode.")
    yOffset = yOffset - 30
    local cb4 = CreateCheckbox(guiFrame, "Shell Context Enabled", "shellContextEnabled", yOffset, "Allows /cd <slash> usage to omit the slash for subsequent commands.")
    yOffset = yOffset - 30
    local cb5 = CreateCheckbox(guiFrame, "Terminal Goodies", "enableTerminalGoodies", yOffset, "Enables the extended set of 50+ terminal-like slash commands.")
    yOffset = yOffset - 30
    local cb6 = CreateCheckbox(guiFrame, "Persist Command History", "persistHistory", yOffset, "If disabled, command usage won't be saved between sessions.")

    -- Close button
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
