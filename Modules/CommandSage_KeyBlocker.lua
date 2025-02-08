-- File: Modules/CommandSage_KeyBlocker.lua
CommandSage_KeyBlocker = {}
local blockerButton = CreateFrame("Button", "CommandSageKeyBlocker", UIParent, "SecureActionButtonTemplate")
blockerButton:Hide()

-- Default keys list.
-- Removed arrow keys (UP, DOWN, LEFT, RIGHT) so these modifiers pass through.
local defaultKeys = {
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
    "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
    -- "UP", "DOWN", "LEFT", "RIGHT",  -- removed so arrow keys are not blocked.
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

-- Debug logging utility.
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
-- ToggleBlock: Enables or disables key blocking.
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
-- IsBlocked: Returns current key blocking status.
--------------------------------------------------------------------------------
function CommandSage_KeyBlocker:IsBlocked()
    return isBlocked
end

--------------------------------------------------------------------------------
-- UpdateKeyBindings: Replaces current key list and reapplies bindings.
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
        print("UpdateKeyBindings expects a table of key strings.")
    end
end

--------------------------------------------------------------------------------
-- RefreshBindings: Re-applies override bindings.
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

-- Remove the OnClick script to prevent interference.
-- blockerButton:SetScript("OnClick", function(self)
--     debugLog("Blocker button clicked.")
-- end)

return CommandSage_KeyBlocker
