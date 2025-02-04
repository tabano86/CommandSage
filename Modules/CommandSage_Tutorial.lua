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
    desc:SetText("Type partial slash commands in chat to see suggestions.\n"..
            "Use '/cmdsage scan' to rescan, '/cmdsage debug' for stats.\n"..
            "Enjoy advanced auto-completion!\n")

    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    closeBtn:SetSize(80, 22)
    closeBtn:SetPoint("BOTTOM", 0, 10)
    closeBtn:SetText("Close")
    closeBtn:SetScript("OnClick", function() frame:Hide() end)
end
