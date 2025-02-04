-- =============================================================================
-- CommandSage_AROverlays.lua
-- "AR-inspired" overlays: subtle animated icons or effects in chat
-- =============================================================================

CommandSage_AROverlays = {}

local overlayFrame = CreateFrame("Frame", "CommandSageAROverlayFrame", UIParent)
overlayFrame:SetSize(200, 200)
overlayFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
overlayFrame:Hide()

local texture = overlayFrame:CreateTexture(nil, "BACKGROUND")
texture:SetAllPoints()
texture:SetTexture("Interface\\AddOns\\CommandSage\\Media\\ArcaneOverlay") -- example
texture:SetAlpha(0.3)

function CommandSage_AROverlays:ShowOverlay()
    overlayFrame:Show()
end

function CommandSage_AROverlays:HideOverlay()
    overlayFrame:Hide()
end

-- We could animate the overlay, reacting to chat triggers:
overlayFrame:SetScript("OnUpdate", function(self, elapsed)
    self.timer = (self.timer or 0) + elapsed
    -- Example: rotate or pulse alpha
    local alpha = 0.3 + 0.2 * math.sin(self.timer * 2)
    texture:SetAlpha(alpha)
end)
