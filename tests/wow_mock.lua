wipe = wipe or function(tbl)
    for k in pairs(tbl) do
        tbl[k]=nil
    end
end
CreateFrame = CreateFrame or function(frameType,name,parent,template)
    local f={}
    function f:SetPoint(...) end
    function f:SetSize(...) end
    function f:Show() end
    function f:Hide() end
    function f:IsShown() return false end
    function f:EnableMouse(...) end
    function f:SetMovable(...) end
    function f:RegisterForDrag(...) end
    function f:SetBackdrop(...) end
    function f:SetBackdropColor(...) end
    function f:SetAlpha(...) end
    function f:SetText(...) end
    function f:GetText() return "" end
    function f:SetCursorPosition(...) end
    function f:SetPropagateKeyboardInput(...) end
    function f:CreateFontString(...)
        local s={}
        function s:SetPoint(...) end
        function s:SetWidth(...) end
        function s:SetText(...) end
        function s:SetJustifyH(...) end
        return s
    end
    function f:CreateTexture(...)
        local t={}
        function t:SetAllPoints(...) end
        function t:SetTexture(...) end
        function t:SetAlpha(...) end
        function t:SetRotation(...) end
        function t:SetSize(...) end
        function t:SetColorTexture(...) end
        function t:Hide(...) end
        function t:Show(...) end
        return t
    end
    function f:HookScript(...) end
    function f:RegisterEvent(...) end
    function f:SetScript(...) end
    return f
end
SlashCmdList = SlashCmdList or {}
UIParent=UIParent or CreateFrame("Frame","UIParent")
ChatFrame1=ChatFrame1 or CreateFrame("Frame","ChatFrame1")
ChatFrame1EditBox=ChatFrame1EditBox or CreateFrame("Frame","ChatFrame1EditBox")
NUM_CHAT_WINDOWS=NUM_CHAT_WINDOWS or 1
IsShiftKeyDown=IsShiftKeyDown or function() return false end
IsControlKeyDown=IsControlKeyDown or function() return false end
InCombatLockdown=InCombatLockdown or function() return false end
GetNumBindings=GetNumBindings or function() return 0 end
GetBinding=GetBinding or function(i) return nil,nil,nil end
SetOverrideBinding=SetOverrideBinding or function(...) end
ClearOverrideBindings=ClearOverrideBindings or function(...) end
date=date or function(fmt) return "12:34:56" end
collectgarbage=collectgarbage or function(...) return 12345 end
GetNumMacros=GetNumMacros or function() return 2,2 end
GetMacroInfo=GetMacroInfo or function(i)
    if i==1 then return "TESTMACRO","icon1","/say Hello" end
    if i==2 then return "WORLD","icon2","/wave" end
    return nil
end
hooksecurefunc=hooksecurefunc or function(...) end
ChatEdit_DeactivateChat=ChatEdit_DeactivateChat or function(...) end
UnitName=UnitName or function(...) return "MockTester" end
GetTime=GetTime or function() return os.time() end
C_Timer=C_Timer or { After=function(sec,func) end }
_G.trim=_G.trim or function(s) return (s:gsub("^%s*(.-)%s*$","%1")) end
SLASH_HELP1=SLASH_HELP1 or "/help"
SlashCmdList["HELP"]=SlashCmdList["HELP"] or function(...) end
C_FriendList=C_FriendList or {
    GetNumFriends=function() return 0 end,
    GetFriendInfoByIndex=function(i) return nil end
}
GetRealZoneText=GetRealZoneText or function() return "Stormwind" end
GetSubZoneText=GetSubZoneText or function() return "Trade District" end
WorldFrame=WorldFrame or {}
