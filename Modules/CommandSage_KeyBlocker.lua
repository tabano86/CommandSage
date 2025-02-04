-- =============================================================================
-- CommandSage_KeyBlocker.lua
-- Securely blocks all key bindings while chat is active.
-- =============================================================================

CommandSage_KeyBlocker = {}

local blockerButton = CreateFrame("Button", "CommandSageKeyBlocker", UIParent, "SecureActionButtonTemplate")
blockerButton:Hide()

-- Comprehensive list of keys based on a standard QWERTY layout and common keys.
local allKeys = {
  -- Letters
  "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
  "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
  -- Numbers
  "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
  -- Function keys
  "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",
  -- Arrow keys
  "UP", "DOWN", "LEFT", "RIGHT",
  -- Common control keys
  "BACKSPACE", "TAB", "CAPSLOCK", "SHIFT", "CTRL", "ALT",
  "NUMLOCK", "SCROLLLOCK", "INSERT", "DELETE",
  "HOME", "END", "PAGEUP", "PAGEDOWN",
  "PRINTSCREEN", "PAUSE", "SPACE",
  -- Punctuation and symbol keys (typical US layout)
  "MINUS", "EQUALS", "LEFTBRACKET", "RIGHTBRACKET",
  "BACKSLASH", "SEMICOLON", "APOSTROPHE", "GRAVE",
  "COMMA", "PERIOD", "SLASH"
}

function CommandSage_KeyBlocker:BlockKeys()
  for _, key in ipairs(allKeys) do
    -- Bind each key to the dummy button so that the key press is consumed.
    SetOverrideBindingClick(blockerButton, true, key, "CommandSageKeyBlocker")
  end
  blockerButton:Show()
end

function CommandSage_KeyBlocker:UnblockKeys()
  ClearOverrideBindings(blockerButton)
  blockerButton:Hide()
end

-- Dummy OnClick handler that does nothing.
blockerButton:SetScript("OnClick", function(self)
  -- Intentionally empty: key events are blocked.
end)
