CommandSage_ConfigGUI = {}
local guiFrame = nil
local usageChartFrame = nil
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
local function ShowUsageChartIfEnabled(parent)
    if not CommandSage_Config.Get("preferences", "usageChartEnabled") then
        if usageChartFrame and usageChartFrame:IsShown() then
            usageChartFrame:Hide()
        end
        return
    end
    if not usageChartFrame then
        usageChartFrame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        usageChartFrame:SetSize(120, 80)
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
function CommandSage_ConfigGUI:InitGUI()
    guiFrame = CreateFrame("Frame", "CommandSageConfigFrame", UIParent, "BasicFrameTemplate")
    guiFrame:SetSize(420, 480)
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
    local cb2 = CreateCheckbox(guiFrame, "Advanced Styling", "advancedStyling", yOffset, "Fancy styling for suggestions.")
    yOffset = yOffset - 30
    local cb3 = CreateCheckbox(guiFrame, "Partial Fuzzy Fallback", "partialFuzzyFallback", yOffset, "Fallback on no prefix match.")
    yOffset = yOffset - 30
    local cb4 = CreateCheckbox(guiFrame, "Shell Context Enabled", "shellContextEnabled", yOffset, "Use /cd <cmd>.")
    yOffset = yOffset - 30
    local cb5 = CreateCheckbox(guiFrame, "Terminal Goodies", "enableTerminalGoodies", yOffset, "Terminal-like slash commands.")
    yOffset = yOffset - 30
    local cb6 = CreateCheckbox(guiFrame, "Persist Command History", "persistHistory", yOffset, "Save command usage.")
    yOffset = yOffset - 30
    local cb7 = CreateCheckbox(guiFrame, "Always Disable Hotkeys in Chat", "alwaysDisableHotkeysInChat", yOffset, "No keybinds in chat.")
    yOffset = yOffset - 30
    local cb8 = CreateCheckbox(guiFrame, "Blizzard All Fallback", "blizzAllFallback", yOffset, "Scan built-in slash commands.")
    yOffset = yOffset - 30
    local cb9 = CreateCheckbox(guiFrame, "Rainbow Border", "rainbowBorderEnabled", yOffset, "Rainbow border for suggestions.")
    yOffset = yOffset - 30
    local cb10 = CreateCheckbox(guiFrame, "Spinning Icon", "spinningIconEnabled", yOffset, "Spinning icon on suggestions.")
    yOffset = yOffset - 30
    local cb11 = CreateCheckbox(guiFrame, "Emote Stickers AR Overlay", "emoteStickersEnabled", yOffset, "Big sticker in AR overlay.")
    yOffset = yOffset - 30
    local cb12 = CreateCheckbox(guiFrame, "Usage Chart", "usageChartEnabled", yOffset, "Displays usage chart in config.")
    yOffset = yOffset - 30
    local cb13 = CreateCheckbox(guiFrame, "Param Glow", "paramGlowEnabled", yOffset, "Glows param suggestions.")
    yOffset = yOffset - 30
    local cb14 = CreateCheckbox(guiFrame, "Chat Input Halo", "chatInputHaloEnabled", yOffset, "Halo effect in chat input.")
    yOffset = yOffset - 30
    local cb15 = CreateCheckbox(guiFrame, "Rune Ring in AR", "arRuneRingEnabled", yOffset, "Rotating rune ring overlay.")
    yOffset = yOffset - 30
    local closeBtn = CreateFrame("Button", nil, guiFrame, "UIPanelButtonTemplate")
    closeBtn:SetSize(80, 22)
    closeBtn:SetPoint("BOTTOM", 0, 10)
    closeBtn:SetText("Close")
    closeBtn:SetScript("OnClick", function()
        guiFrame:Hide()
    end)
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
