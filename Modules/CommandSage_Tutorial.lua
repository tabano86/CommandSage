-- =============================================================================
-- CommandSage_Tutorial.lua
-- Basic tutorial pop-up
-- =============================================================================

CommandSage_Tutorial = {}

function CommandSage_Tutorial:ShowTutorialPrompt()
    local frame = CreateFrame("Frame", "CommandSageTutorialFrame", UIParent, "BasicFrameTemplate")
    frame:SetSize(420, 220)
    frame:SetPoint("CENTER")
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -10)
    title:SetText("Welcome to CommandSage Next-Gen!")

    local desc = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    desc:SetPoint("TOPLEFT", 20, -40)
    desc:SetWidth(380)
    desc:SetText(
            "Type a slash command (e.g. /dance, /cmdsage) to see context-aware suggestions.\n" ..
                    "Use arrow keys, Tab, or Up/Down to navigate, Enter to commit.\n" ..
                    "If terminal goodies are on, you have extras like /cls to clear chat.\n" ..
                    "Try '/cmdsage scan' to re-scan or '/cmdsage debug' for stats.\nEnjoy your new auto-completion experience!"
    )

    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    closeBtn:SetSize(80, 22)
    closeBtn:SetPoint("BOTTOM", 0, 10)
    closeBtn:SetText("Close")
    closeBtn:SetScript("OnClick", function()
        frame:Hide()
    end)
end
