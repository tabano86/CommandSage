-- tests/wow_mock.lua
-- Mocks/stubs for WoW APIs that CommandSage references.

-- Stub out any existing global first to avoid overwrite
_G.wipe = _G.wipe or function(tbl)
    -- WoW's wipe() clears a table in-place
    for k in pairs(tbl) do
        tbl[k] = nil
    end
end

_G.CreateFrame = _G.CreateFrame or function(frameType, name, parent, template)
    local f = {}
    f.children = {}
    function f:SetPoint(...) end
    function f:SetSize(...) end
    function f:Show() end
    function f:Hide() end
    function f:IsShown() return false end
    function f:EnableMouse(...) end
    function f:SetMovable(...) end
    function f:RegisterForDrag(...) end
    function f:SetScript(...) end
    function f:HookScript(...) end
    function f:SetBackdrop(...) end
    function f:SetBackdropColor(...) end
    function f:SetAlpha(...) end
    function f:SetText(...) end
    function f:GetText() return "" end
    function f:SetCursorPosition(...) end
    function f:SetPropagateKeyboardInput(...) end
    function f:CreateTexture()
        return {
            SetAllPoints = function() end,
            SetTexture   = function() end,
            SetRotation  = function() end,
            SetColorTexture = function(...) end,
            Hide         = function() end,
            Show         = function() end
        }
    end
    return f
end

_G.SlashCmdList = _G.SlashCmdList or {}
_G.NUM_CHAT_WINDOWS = _G.NUM_CHAT_WINDOWS or 1
_G.ChatFrame1 = _G.ChatFrame1 or {}
_G.ChatFrame1EditBox = _G.ChatFrame1EditBox or {
    SetText = function(self, txt) self._text = txt end,
    GetText = function(self) return self._text or "" end,
    SetCursorPosition = function(...) end,
    HookScript = function(...) end,
    SetPropagateKeyboardInput = function(...) end,
    RegisterEvent = function(...) end,
}

_G.IsShiftKeyDown    = _G.IsShiftKeyDown    or function() return false end
_G.IsControlKeyDown  = _G.IsControlKeyDown  or function() return false end
_G.InCombatLockdown  = _G.InCombatLockdown  or function() return false end
_G.GetNumBindings    = _G.GetNumBindings    or function() return 0 end
_G.GetBinding        = _G.GetBinding        or function(i) return nil,nil,nil end
_G.SetOverrideBinding= _G.SetOverrideBinding or function(...) end
_G.ClearOverrideBindings = _G.ClearOverrideBindings or function(...) end

_G.date = _G.date or function(fmt) return "12:34:56" end
_G.collectgarbage = _G.collectgarbage or function(...) return 12345 end
_G.print = _G.print or function(...) end  -- you can re-enable if you want real prints

_G.GetNumMacros = _G.GetNumMacros or function() return 2,2 end
_G.GetMacroInfo = _G.GetMacroInfo or function(index)
    if index == 1 then return "TESTMACRO","icon1","/say Hello" end
    if index == 2 then return "WORLD","icon2","/wave" end
    return nil
end

_G.hooksecurefunc = _G.hooksecurefunc or function(...) end
_G.ChatEdit_DeactivateChat = _G.ChatEdit_DeactivateChat or function(...) end
_G.UnitName = _G.UnitName or function(...) return "MockTester" end
_G.GetTime = _G.GetTime or function() return os.time() end
_G.C_Timer = _G.C_Timer or {
    After = function(sec, func) end
}
_G._G.trim = _G._G.trim or function(s) return (s:gsub("^%s*(.-)%s*$", "%1")) end
_G.SLASH_HELP1 = "/help"
SlashCmdList["HELP"] = SlashCmdList["HELP"] or function(...) end

_G.C_FriendList = _G.C_FriendList or {
    GetNumFriends = function() return 0 end,
    GetFriendInfoByIndex = function(i) return nil end
}

_G.GetRealZoneText = _G.GetRealZoneText or function() return "Stormwind" end
_G.GetSubZoneText  = _G.GetSubZoneText  or function() return "Trade District" end

-- Provide some fallback so slash-based commands won't break.
_G.SLASH_RELOAD1 = _G.SLASH_RELOAD1 or "/reload"
_G.SlashCmdList["RELOAD"] = function() end

-- Etc. Add any additional mocks as your code references them.
