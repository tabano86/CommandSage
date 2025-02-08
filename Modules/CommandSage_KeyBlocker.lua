-- File: Modules/CommandSage_KeyBlocker.lua
CommandSage_KeyBlocker = {}
local blockerButton = CreateFrame("Button", "CommandSageKeyBlocker", UIParent, "SecureActionButtonTemplate")
blockerButton:Hide()

-- Default keys list; this list can be replaced via UpdateKeyBindings()
local defaultKeys = {
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
    "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
    "UP", "DOWN", "LEFT", "RIGHT",
    "BACKSPACE", "TAB", "CAPSLOCK",
    "NUMLOCK", "SCROLLLOCK", "INSERT", "DELETE", "HOME", "END", "PAGEUP", "PAGEDOWN",
    "PRINTSCREEN", "PAUSE", "SPACE",
    "MINUS", "EQUALS", "LEFTBRACKET", "RIGHTBRACKET",
    "BACKSLASH", "SEMICOLON", "APOSTROPHE", "GRAVE", "COMMA", "PERIOD", "SLASH",
    "LSHIFT", "RSHIFT", "LCTRL", "RCTRL", "LALT", "RALT",
    "MOUSEWHEELUP", "MOUSEWHEELDOWN"
}

-- Expose the keys list; external modules can override this list.
CommandSage_KeyBlocker.allKeys = defaultKeys

-- Internal state variable for block status.
local isBlocked = false

-- Logs a message if CommandSage.debugMode is enabled.
local function debugLog(msg)
    if CommandSage and CommandSage.debugMode then
        print("|cff999999[KeyBlocker Debug]|r", tostring(msg))
    end
end

--------------------------------------------------------------------------------
-- BlockKeys: Overrides bindings for all keys in the list.
--------------------------------------------------------------------------------
function CommandSage_KeyBlocker:BlockKeys()
    local keys = self.allKeys or defaultKeys
    for _, key in ipairs(keys) do
        local success = pcall(SetOverrideBindingClick, blockerButton, true, key, "CommandSageKeyBlocker")
        if not success then
            debugLog("Failed to bind key: " .. key)
        else
            debugLog("Bound key: " .. key)
        end
    end
    blockerButton:Show()
    isBlocked = true
    debugLog("All keys blocked.")
end

--------------------------------------------------------------------------------
-- UnblockKeys: Clears all override bindings and hides the blocker button.
--------------------------------------------------------------------------------
function CommandSage_KeyBlocker:UnblockKeys()
    local success = pcall(ClearOverrideBindings, blockerButton)
    if not success then
        debugLog("Error clearing override bindings.")
    else
        debugLog("Override bindings cleared.")
    end
    blockerButton:Hide()
    isBlocked = false
end

--------------------------------------------------------------------------------
-- ToggleBlock: Enables or disables key blocking based on the state parameter.
-- If state is true then keys are blocked; if false, keys are unblocked.
--------------------------------------------------------------------------------
function CommandSage_KeyBlocker:ToggleBlock(state)
    if state == nil then
        state = not isBlocked
    end
    if state then
        self:BlockKeys()
    else
        self:UnblockKeys()
    end
    return isBlocked
end

--------------------------------------------------------------------------------
-- IsBlocked: Returns the current key blocking status.
--------------------------------------------------------------------------------
function CommandSage_KeyBlocker:IsBlocked()
    return isBlocked
end

--------------------------------------------------------------------------------
-- UpdateKeyBindings: Replaces the current keys list with a new one and
-- reapplies the override bindings if currently blocked.
-- newKeys should be a table of key names.
--------------------------------------------------------------------------------
function CommandSage_KeyBlocker:UpdateKeyBindings(newKeys)
    if type(newKeys) == "table" then
        self.allKeys = newKeys
        debugLog("Key list updated.")
        if isBlocked then
            self:UnblockKeys()
            self:BlockKeys()
        end
    else
        safePrint("UpdateKeyBindings expects a table of key strings.")
    end
end

--------------------------------------------------------------------------------
-- RefreshBindings: Re-applies override bindings for all keys.
-- Useful if other addons or events clear these bindings.
--------------------------------------------------------------------------------
function CommandSage_KeyBlocker:RefreshBindings()
    if isBlocked then
        self:UnblockKeys()
        self:BlockKeys()
        debugLog("Bindings refreshed.")
    else
        debugLog("Bindings not refreshed because keys are not currently blocked.")
    end
end

--------------------------------------------------------------------------------
-- Example Event Hook: Automatically refresh key blocking on zone change.
-- (Uncomment the following lines if you want to auto-refresh bindings on a zone update.)
--------------------------------------------------------------------------------
-- local zoneFrame = CreateFrame("Frame")
-- zoneFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
-- zoneFrame:SetScript("OnEvent", function(self, event)
--     if CommandSage_KeyBlocker and CommandSage_KeyBlocker:IsBlocked() then
--         CommandSage_KeyBlocker:RefreshBindings()
--     end
-- end)

--------------------------------------------------------------------------------
-- Additional Click Logic (if needed): Currently a placeholder.
--------------------------------------------------------------------------------
blockerButton:SetScript("OnClick", function(self)
    -- Placeholder for additional click handling logic.
    debugLog("Blocker button clicked.")
end)

return CommandSage_KeyBlocker
