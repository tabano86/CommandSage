-- File: Modules/CommandSage_AROverlays.lua
-- Enhanced AR Overlays module.
-- This module displays a central overlay with a background texture (e.g. an arcane overlay),
-- an optional rotating “rune ring” texture, and an optional “sticker” (such as an emote).
-- Animation parameters and enabled states are read from CommandSage_Config preferences.
-- The overlay supports smooth fade–in and fade–out transitions as well as configuration updates.

CommandSage_AROverlays = {}

-- Create the main overlay frame
local overlayFrame = CreateFrame("Frame", "CommandSageAROverlayFrame", UIParent, "BackdropTemplate")
overlayFrame:SetSize(200, 200)
overlayFrame:SetPoint("CENTER")
overlayFrame:Hide()

-- Create the background texture.
local bgTex = overlayFrame:CreateTexture(nil, "BACKGROUND")
bgTex:SetAllPoints()
bgTex:SetTexture("Interface\\AddOns\\CommandSage\\Media\\ArcaneOverlay")
bgTex:SetAlpha(0.3)

-- Create the rune ring texture.
local runeRing = overlayFrame:CreateTexture(nil, "ARTWORK")
runeRing:SetPoint("CENTER")
runeRing:SetTexture("Interface\\AddOns\\CommandSage\\Media\\RuneRing")
runeRing:SetSize(220, 220)
runeRing:Hide()

-- Create the sticker texture.
local sticker = overlayFrame:CreateTexture(nil, "OVERLAY")
sticker:SetTexture("Interface\\AddOns\\CommandSage\\Media\\EmoteSticker")
sticker:SetSize(64, 64)
sticker:SetPoint("CENTER", 0, 80)
sticker:Hide()

-- Internal state variables for animation.
overlayFrame.timer = 0
overlayFrame.isFadingIn = false
overlayFrame.isFadingOut = false
overlayFrame.fadeProgress = 0

-- Default animation parameters (can be overridden via config):
local defaults = {
    baseAlpha = 0.3,           -- minimum alpha for background texture
    alphaAmplitude = 0.2,      -- oscillation amplitude for background alpha
    oscillationSpeed = 2,      -- how fast the background alpha oscillates (radians/sec)
    ringRotationSpeed = 0.5,   -- rotation speed of the rune ring (radians/sec)
    fadeDuration = 0.5         -- seconds to fade in/out overlay
}

-- Helper: fetch config values with safe defaults.
local function GetOverlaySetting(key)
    if CommandSage_Config and CommandSage_Config.Get("preferences", key) ~= nil then
        return CommandSage_Config.Get("preferences", key)
    end
    return defaults[key]
end

-- Update the overlay’s animation (called on every OnUpdate).
local function UpdateAnimation(self, elapsed)
    -- Update the internal timer.
    self.timer = self.timer + elapsed

    -- Oscillate the background alpha.
    local baseAlpha = GetOverlaySetting("baseAlpha")
    local amp = GetOverlaySetting("alphaAmplitude")
    local oscSpeed = GetOverlaySetting("oscillationSpeed")
    local newAlpha = baseAlpha + amp * math.sin(self.timer * oscSpeed)
    bgTex:SetAlpha(newAlpha)

    -- Rotate the rune ring if visible.
    if runeRing:IsShown() then
        local rotSpeed = GetOverlaySetting("ringRotationSpeed")
        runeRing:SetRotation(self.timer * rotSpeed)
    end

    -- Handle fade–in/out transitions.
    local fadeDur = GetOverlaySetting("fadeDuration")
    if self.isFadingIn then
        self.fadeProgress = math.min(self.fadeProgress + elapsed / fadeDur, 1)
        overlayFrame:SetAlpha(self.fadeProgress)
        if self.fadeProgress >= 1 then
            self.isFadingIn = false
        end
    elseif self.isFadingOut then
        self.fadeProgress = math.max(self.fadeProgress - elapsed / fadeDur, 0)
        overlayFrame:SetAlpha(self.fadeProgress)
        if self.fadeProgress <= 0 then
            self.isFadingOut = false
            self:Hide()
        end
    end
end

-- Public API: Show the overlay with fade–in.
function CommandSage_AROverlays:ShowOverlay()
    if not overlayFrame then return end

    overlayFrame:Show()
    overlayFrame.timer = 0
    overlayFrame.fadeProgress = 0
    overlayFrame.isFadingIn = true
    overlayFrame.isFadingOut = false
    overlayFrame:SetAlpha(0)

    -- Show or hide the rune ring based on config.
    if CommandSage_Config and CommandSage_Config.Get("preferences", "arRuneRingEnabled") then
        runeRing:Show()
    else
        runeRing:Hide()
    end

    -- Show or hide the sticker based on config.
    if CommandSage_Config and CommandSage_Config.Get("preferences", "emoteStickersEnabled") then
        sticker:Show()
    else
        sticker:Hide()
    end

    debugLog("Overlay shown.")
end

-- Public API: Hide the overlay with fade–out.
function CommandSage_AROverlays:HideOverlay()
    if not overlayFrame or not overlayFrame:IsShown() then return end
    overlayFrame.isFadingOut = true
    overlayFrame.isFadingIn = false
    overlayFrame.fadeProgress = overlayFrame:GetAlpha() or 1
    debugLog("Overlay fading out.")
end

-- Public API: Toggle the overlay.
function CommandSage_AROverlays:ToggleOverlay()
    if overlayFrame and overlayFrame:IsShown() then
        self:HideOverlay()
    else
        self:ShowOverlay()
    end
end

-- Set the OnUpdate script for the overlay frame.
overlayFrame:SetScript("OnUpdate", UpdateAnimation)

-- Optionally, add a function to update the overlay if configuration changes.
function CommandSage_AROverlays:Refresh()
    if overlayFrame:IsShown() then
        -- Re-read configuration and update each texture as needed.
        if CommandSage_Config then
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
        debugLog("Overlay refreshed with updated configuration.")
    end
end

-- Utility debug logging function.
function debugLog(msg)
    if CommandSage and CommandSage.debugMode then
        print("|cff999999[AROverlays Debug]|r", msg)
    end
end

return CommandSage_AROverlays
