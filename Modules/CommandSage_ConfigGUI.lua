-- File: Modules/CommandSage_ConfigGUI.lua
CommandSage_ConfigGUI = {}
local guiFrame, usageChartFrame
local controlsCache = {}

-- Utility to create a generic control wrapper
local function CreateControl(controlType, parent, name, template)
    local control = CreateFrame(controlType, name, parent, template)
    return control
end

-- Enhanced checkbox creation with caching and custom styling.
local function CreateCheckbox(parent, label, cvar, offsetY, tooltip)
    local cb = CreateControl("CheckButton", parent, nil, "InterfaceOptionsCheckButtonTemplate")
    cb.Text:SetText(label)
    cb:SetPoint("TOPLEFT", 20, offsetY)
    cb:SetScript("OnClick", function(self)
        local val = self:GetChecked() == true
        CommandSage_Config.Set("preferences", cvar, val)
        if tooltip then
            GameTooltip:Hide()
        end
        -- Fire an event to update dependent UI elements if needed.
        if CommandSage_DeveloperAPI and CommandSage_DeveloperAPI.FireEvent then
            CommandSage_DeveloperAPI:FireEvent("CONFIG_UPDATED", cvar, val)
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
    local currentVal = CommandSage_Config.Get("preferences", cvar)
    if currentVal ~= nil then
        cb:SetChecked(currentVal)
    end
    return cb
end

-- Enhanced slider creation for numeric settings (e.g., UI scale)
local function CreateSlider(parent, label, cvar, offsetY, minVal, maxVal, step, tooltip)
    local slider = CreateControl("Slider", parent, nil, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", 20, offsetY)
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    slider:SetSize(200, 20)
    _G[slider:GetName().."Low"]:SetText(minVal)
    _G[slider:GetName().."High"]:SetText(maxVal)
    _G[slider:GetName().."Text"]:SetText(label)
    slider:SetScript("OnValueChanged", function(self, value)
        CommandSage_Config.Set("preferences", cvar, value)
        _G[slider:GetName().."Text"]:SetText(label.." ("..value..")")
        if tooltip then
            GameTooltip:Hide()
        end
    end)
    slider:SetScript("OnEnter", function(self)
        if tooltip then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(tooltip, 1, 1, 1, 1, true)
        end
    end)
    slider:SetScript("OnLeave", function(self)
        if tooltip then
            GameTooltip:Hide()
        end
    end)
    slider:SetValue(CommandSage_Config.Get("preferences", cvar) or minVal)
    return slider
end

-- Enhanced dropdown creation for theme selection or similar options.
local function CreateDropdown(parent, label, cvar, options, offsetY, tooltip)
    local dd = CreateControl("Frame", parent, nil, "UIDropDownMenuTemplate")
    dd:SetPoint("TOPLEFT", 20, offsetY)
    UIDropDownMenu_SetWidth(dd, 180)
    UIDropDownMenu_SetText(dd, label)
    dd.initialize = function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        for _, option in ipairs(options) do
            info.text = option
            info.func = function(self)
                CommandSage_Config.Set("preferences", cvar, self.value)
                UIDropDownMenu_SetSelectedValue(dd, self.value)
                if tooltip then
                    GameTooltip:Hide()
                end
            end
            info.value = option
            info.checked = (CommandSage_Config.Get("preferences", cvar) == option)
            UIDropDownMenu_AddButton(info, level)
        end
    end
    dd:SetScript("OnEnter", function(self)
        if tooltip then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(tooltip, 1, 1, 1, 1, true)
        end
    end)
    dd:SetScript("OnLeave", function(self)
        if tooltip then
            GameTooltip:Hide()
        end
    end)
    return dd
end

-- Live update the usage chart with additional visual styling.
local function ShowUsageChartIfEnabled(parent)
    if not CommandSage_Config.Get("preferences", "usageChartEnabled") then
        if usageChartFrame and usageChartFrame:IsShown() then
            usageChartFrame:Hide()
        end
        return
    end
    if not usageChartFrame then
        usageChartFrame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        usageChartFrame:SetSize(150, 100)
        usageChartFrame:SetPoint("TOPRIGHT", -40, -40)
        usageChartFrame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 8,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        usageChartFrame:SetBackdropColor(0, 0, 0, 0.8)
        usageChartFrame.text = usageChartFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        usageChartFrame.text:SetPoint("CENTER")
        -- Add a subtle animated pulse effect:
        usageChartFrame.pulse = 0
        usageChartFrame:SetScript("OnUpdate", function(self, elapsed)
            self.pulse = self.pulse + elapsed
            local alpha = 0.8 + 0.1 * math.sin(self.pulse * 2)
            self:SetBackdropColor(0, 0, 0, alpha)
        end)
    end
    local usageData = CommandSageDB.usageData
    local total = 0
    if usageData then
        for _, v in pairs(usageData) do
            total = total + v
        end
    end
    if total == 0 then
        usageChartFrame.text:SetText("No usage data yet.")
    else
        usageChartFrame.text:SetText("Usage Sum:\n" .. total)
    end
    usageChartFrame:Show()
end

-- Initialize the configuration GUI with enhanced controls and layout reflow.
function CommandSage_ConfigGUI:InitGUI()
    guiFrame = CreateFrame("Frame", "CommandSageConfigFrame", UIParent, "BasicFrameTemplate")
    guiFrame:SetSize(500, 600)  -- increased size for more controls
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
    local controls = {
        { label = "Enable Animated AutoType", cvar = "animateAutoType", tooltip = "Simulates typing slash commands." },
        { label = "Advanced Styling", cvar = "advancedStyling", tooltip = "Fancy styling for suggestions." },
        { label = "Partial Fuzzy Fallback", cvar = "partialFuzzyFallback", tooltip = "Fallback on no prefix match." },
        { label = "Shell Context Enabled", cvar = "shellContextEnabled", tooltip = "Use /cd <cmd>." },
        { label = "Terminal Goodies", cvar = "enableTerminalGoodies", tooltip = "Terminal-like slash commands." },
        { label = "Persist Command History", cvar = "persistHistory", tooltip = "Save command usage." },
        { label = "Disable Hotkeys in Chat", cvar = "alwaysDisableHotkeysInChat", tooltip = "Disable keybinds while typing." },
        { label = "Blizzard All Fallback", cvar = "blizzAllFallback", tooltip = "Scan built-in slash commands." },
        { label = "Rainbow Border", cvar = "rainbowBorderEnabled", tooltip = "Rainbow border for suggestions." },
        { label = "Spinning Icon", cvar = "spinningIconEnabled", tooltip = "Spinning icon on suggestions." },
        { label = "Emote Stickers AR Overlay", cvar = "emoteStickersEnabled", tooltip = "Big sticker in AR overlay." },
        { label = "Usage Chart", cvar = "usageChartEnabled", tooltip = "Displays usage chart in config." },
        { label = "Param Glow", cvar = "paramGlowEnabled", tooltip = "Glows param suggestions." },
        { label = "Chat Input Halo", cvar = "chatInputHaloEnabled", tooltip = "Halo effect in chat input." },
        { label = "Rune Ring in AR", cvar = "arRuneRingEnabled", tooltip = "Rotating rune ring overlay." },
    }
    for i, control in ipairs(controls) do
        local cb = CreateCheckbox(guiFrame, control.label, control.cvar, yOffset, control.tooltip)
        yOffset = yOffset - 30
    end

    -- Add an extra slider for UI scale control.
    local scaleSlider = CreateSlider(guiFrame, "UI Scale", "uiScale", yOffset, 0.5, 2.0, 0.05, "Adjust the overall scale of the UI elements.")
    yOffset = yOffset - 40

    -- Add a dropdown for UI Theme selection.
    local themeDropdown = CreateDropdown(guiFrame, "UI Theme", "uiTheme", {"dark", "light", "classic"}, yOffset, "Select your UI theme.")
    yOffset = yOffset - 40

    -- Add a reset button for configuration.
    local resetBtn = CreateControl("Button", guiFrame, nil, "UIPanelButtonTemplate")
    resetBtn:SetSize(100, 22)
    resetBtn:SetPoint("BOTTOM", guiFrame, "BOTTOM", 0, 10)
    resetBtn:SetText("Reset Config")
    resetBtn:SetScript("OnClick", function()
        CommandSage_Config:ResetPreferences()
        guiFrame:Hide()
        safePrint("Configuration has been reset to defaults.")
    end)

    -- Set up the usage chart to update on show.
    guiFrame:SetScript("OnShow", function()
        ShowUsageChartIfEnabled(guiFrame)
    end)
    guiFrame:SetScript("OnHide", function()
        if usageChartFrame then
            usageChartFrame:Hide()
        end
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

return CommandSage_ConfigGUI
