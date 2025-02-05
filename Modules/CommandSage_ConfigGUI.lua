-- =============================================================================
-- CommandSage_ConfigGUI.lua
-- =============================================================================

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
            bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile     = true, tileSize = 16, edgeSize = 8,
            insets   = { left = 2, right = 2, top = 2, bottom = 2 },
        })
        usageChartFrame:SetBackdropColor(0,0,0,0.8)

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
        usageChartFrame.text:SetText("Usage Sum:\n"..total)
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

    -- New toggles
    local cb9 = CreateCheckbox(guiFrame, "Rainbow Border", "rainbowBorderEnabled", yOffset, "Adds a rainbow border to suggestions.")
    yOffset = yOffset - 30
    local cb10 = CreateCheckbox(guiFrame, "Spinning Icon", "spinningIconEnabled", yOffset, "Displays a spinning icon on suggestions.")
    yOffset = yOffset - 30
    local cb11 = CreateCheckbox(guiFrame, "Emote Stickers AR Overlay", "emoteStickersEnabled", yOffset, "Show a big sticker in AR overlay.")
    yOffset = yOffset - 30
    local cb12 = CreateCheckbox(guiFrame, "Usage Chart", "usageChartEnabled", yOffset, "Displays a usage chart in the config.")
    yOffset = yOffset - 30
    local cb13 = CreateCheckbox(guiFrame, "Param Glow", "paramGlowEnabled", yOffset, "Glows param suggestions in red.")
    yOffset = yOffset - 30
    local cb14 = CreateCheckbox(guiFrame, "Chat Input Halo", "chatInputHaloEnabled", yOffset, "Gives a halo effect in chat input.")
    yOffset = yOffset - 30
    local cb15 = CreateCheckbox(guiFrame, "Rune Ring in AR", "arRuneRingEnabled", yOffset, "Shows a rotating rune ring overlay.")
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
