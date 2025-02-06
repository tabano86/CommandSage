CommandSage_KeyBlocker = {}
local blockerButton = CreateFrame("Button", "CommandSageKeyBlocker", UIParent, "SecureActionButtonTemplate")
blockerButton:Hide()

local allKeys = {
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
CommandSage_KeyBlocker.allKeys = allKeys

function CommandSage_KeyBlocker:BlockKeys()
    local keys = self.allKeys or allKeys
    for _, key in ipairs(keys) do
        SetOverrideBindingClick(blockerButton, true, key, "CommandSageKeyBlocker")
    end
    blockerButton:Show()
end

function CommandSage_KeyBlocker:UnblockKeys()
    ClearOverrideBindings(blockerButton)
    blockerButton:Hide()
end

blockerButton:SetScript("OnClick", function(self)
    -- Additional click logic if needed.
end)
return CommandSage_KeyBlocker
