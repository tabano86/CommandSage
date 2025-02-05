-- =============================================================================
-- CommandSage_AROverlays.lua
-- Animated overlay for fun + new rune ring, emote stickers
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

-- Additional "rune ring"
local runeRing = f:CreateTexture(nil, "ARTWORK")
runeRing:SetPoint("CENTER")
runeRing:SetTexture("Interface\\AddOns\\CommandSage\\Media\\RuneRing")
runeRing:SetSize(220,220)
runeRing:Hide()

-- Emote sticker
local sticker = f:CreateTexture(nil, "OVERLAY")
sticker:SetTexture("Interface\\AddOns\\CommandSage\\Media\\EmoteSticker")
sticker:SetSize(64,64)
sticker:SetPoint("CENTER", 0, 80)
sticker:Hide()

f:SetScript("OnUpdate", function(self, elapsed)
    self.timer = (self.timer or 0) + elapsed
    local a = 0.3 + 0.2 * math.sin(self.timer * 2)
    tex:SetAlpha(a)

    if runeRing:IsShown() then
        -- slight rotation
        local rot = self.timer * 0.5
        runeRing:SetRotation(rot)
    end
end)

function CommandSage_AROverlays:ShowOverlay()
    f:Show()
    if CommandSage_Config.Get("preferences", "arRuneRingEnabled") then
        runeRing:Show()
    else
        runeRing:Hide()
    end
    if CommandSage_Config.Get("preferences", "emoteStickersEnabled") then
        sticker:Show()
    else
        sticker:Hide()
    end
end

function CommandSage_AROverlays:HideOverlay()
    f:Hide()
end

function CommandSage_AROverlays:ToggleOverlay()
    if f:IsShown() then
        self:HideOverlay()
    else
        self:ShowOverlay()
    end
end
