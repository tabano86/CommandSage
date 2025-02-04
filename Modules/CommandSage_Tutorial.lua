-- =============================================================================
-- CommandSage_Tutorial.lua
-- Basic tutorial pop-up with optional fade-in
-- =============================================================================

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

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -10)
    title:SetText("Welcome to CommandSage Next-Gen!")

    local desc = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    desc:SetPoint("TOPLEFT", 20, -40)
    desc:SetWidth(380)
    desc:SetText(
            "Type a slash command (e.g. /dance, /cmdsage) to see context-aware suggestions.\n" ..
                    "Use arrow keys, Tab, or Up/Down to navigate, Enter to commit.\n" ..
                    "Check out advanced features like shell context (/cd <cmd>), partial-fallback, etc.\n" ..
                    "Customize UI theme, scale, or advanced settings via /cmdsage gui.\n" ..
                    "Enjoy your new auto-completion experience!"
    )

    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    closeBtn:SetSize(80, 22)
    closeBtn:SetPoint("BOTTOM", 0, 10)
    closeBtn:SetText("Close")
    closeBtn:SetScript("OnClick", function()
        frame:Hide()
    end)

    FadeInIfEnabled(frame)
end

function CommandSage_Tutorial:RefreshTutorialPrompt()
    print("Refreshing tutorial prompt...")
    self:ShowTutorialPrompt()
end
