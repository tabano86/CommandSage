-- Modules/CommandSage_Tutorial.lua
CommandSage_Tutorial = {}

local function FadeInIfEnabled(frame)
    if CommandSage_Config.Get("preferences", "tutorialFadeIn") then
        frame:SetAlpha(0)
        UIFrameFadeIn(frame, 1.0, 0, 1)
    end
end

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

    -- Ensure it's shown
    frame:Show()

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -10)
    title:SetText("Welcome to CommandSage Next-Gen 4.3!")

    local desc = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    desc:SetPoint("TOPLEFT", 20, -40)
    desc:SetWidth(380)
    desc:SetText("Type a slash command to see suggestions. Use arrow keys or Tab to navigate. Customize via /cmdsage gui.")

    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    closeBtn:SetSize(80, 22)
    closeBtn:SetPoint("BOTTOM", 0, 10)
    closeBtn:SetText("Close")
    closeBtn:SetScript("OnClick", function()
        frame:Hide()
    end)
    frame.CloseButton = closeBtn

    FadeInIfEnabled(frame)
end

function CommandSage_Tutorial:RefreshTutorialPrompt()
    self:ShowTutorialPrompt()
end
