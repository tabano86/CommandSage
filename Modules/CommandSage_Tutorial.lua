-- =============================================================================
-- CommandSage_Tutorial.lua
-- Shows a basic tutorial or help popup
-- =============================================================================

CommandSage_Tutorial = {}

function CommandSage_Tutorial:ShowTutorialPrompt()
    local frame = CreateFrame("Frame", "CommandSageTutorialFrame", UIParent, "BasicFrameTemplate")
    frame:SetSize(400, 200)
    frame:SetPoint("CENTER")
    frame:EnableMouse(true)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self) self:StartMoving() end)
    frame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -10)
    title:SetText("Welcome to CommandSage!")

    local desc = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    desc:SetPoint("TOPLEFT", 20, -40)
    desc:SetWidth(360)
    desc:SetText("Use '/cmdsage' for basic commands.\nType slash commands in chat and see real-time suggestions!\nYou can also re-scan with '/cmdsage scan'.\nEnjoy your advanced auto-completion experience!")

    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    closeBtn:SetSize(80, 22)
    closeBtn:SetText("Close")
    closeBtn:SetPoint("BOTTOM", 0, 10)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)
end
