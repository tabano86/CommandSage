CommandSage_KeyBlocker = {}
local blockerButton = CreateFrame("Button", "CommandSageKeyBlocker", UIParent, "SecureActionButtonTemplate")
blockerButton:Hide()
local allKeys = {
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
    "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
    "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",
    "UP", "DOWN", "LEFT", "RIGHT", "BACKSPACE", "TAB", "CAPSLOCK",
    "NUMLOCK", "SCROLLLOCK", "INSERT", "DELETE", "HOME", "END", "PAGEUP", "PAGEDOWN",
    "PRINTSCREEN", "PAUSE", "SPACE", "MINUS", "EQUALS", "LEFTBRACKET", "RIGHTBRACKET",
    "BACKSLASH", "SEMICOLON", "APOSTROPHE", "GRAVE", "COMMA", "PERIOD", "SLASH"
}
CommandSage_KeyBlocker.allKeys = allKeys
function CommandSage_KeyBlocker:BlockKeys()
    for _, key in ipairs(allKeys) do
        SetOverrideBindingClick(blockerButton, true, key, "CommandSageKeyBlocker")
    end
    blockerButton:Show()
end
function CommandSage_KeyBlocker:UnblockKeys()
    ClearOverrideBindings(blockerButton)
    blockerButton:Hide()
end
blockerButton:SetScript("OnClick", function(self)
end)
