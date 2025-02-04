-- =============================================================================
-- CommandSage_AROverlays.lua
-- Animated overlay for fun
-- =============================================================================

CommandSage_AROverlays = {}

local f = CreateFrame("Frame", "CommandSageAROverlayFrame", UIParent)
f:SetSize(200, 200)
f:SetPoint("CENTER")
f:Hide()

local tex = f:CreateTexture(nil, "BACKGROUND")
tex:SetAllPoints()
tex:SetTexture("Interface\\AddOns\\CommandSage\\Media\\ArcaneOverlay")
tex:SetAlpha(0.3)

f:SetScript("OnUpdate", function(self, elapsed)
    self.timer = (self.timer or 0) + elapsed
    local a = 0.3 + 0.2 * math.sin(self.timer * 2)
    tex:SetAlpha(a)
end)

function CommandSage_AROverlays:ShowOverlay()
    f:Show()
end

function CommandSage_AROverlays:HideOverlay()
    f:Hide()
end

function CommandSage_AROverlays:ToggleOverlay()
    if f:IsShown() then
        f:Hide()
    else
        f:Show()
    end
end

