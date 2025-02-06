-------------------------------------------------------------
-- tests/wow_mock.lua
-- A comprehensive WoW Classic API stub for testing CommandSage.
-- This file is our single source of truth for WoW Classic API stubs.
-- It mimics the WoW Classic environment closely.
-------------------------------------------------------------

-- Force our stub to be used by clearing any preexisting CreateFrame.
_G.CreateFrame = nil

print("wow_mock.lua loaded (enhanced).")

-----------------------------------------
-- Provide securecall and UIFrameFadeIn
-----------------------------------------
if not securecall then
    -- In WoW, securecall invokes a function in a protected environment.
    function securecall(fn, ...)
        return fn(...)
    end
end

-- Ensure 'unpack' exists globally (Lua 5.2+ uses table.unpack)
if not _G.unpack then
    if table and table.unpack then
        _G.unpack = table.unpack
    end
end

if not UIFrameFadeIn then
    function UIFrameFadeIn(frame, duration, fromAlpha, toAlpha)
        -- Simple stub: immediately set final alpha.
        frame:SetAlpha(toAlpha)
    end
end

-----------------------------------------
-- Utility Functions
-----------------------------------------
if not wipe then
    function wipe(tbl)
        for k in pairs(tbl) do
            tbl[k] = nil
        end
        return tbl
    end
end

-----------------------------------------
-- Timer API Stub
-----------------------------------------
if not C_Timer then
    C_Timer = {
        After = function(sec, func)
            -- In tests, immediately call the function.
            func()
        end
    }
end

-----------------------------------------
-- Zone and Time API Stubs
-----------------------------------------
if not GetRealZoneText then
    GetRealZoneText = function()
        return "Stormwind"
    end
end

if not GetSubZoneText then
    GetSubZoneText = function()
        return "Trade District"
    end
end

if not GetTime then
    GetTime = function()
        return os.time()
    end
end

if not date then
    date = function(fmt)
        return "12:34:56"
    end
end

-----------------------------------------
-- Chat API Stubs
-----------------------------------------
-- Simulate ChatEdit_DeactivateChat (e.g. when chat input loses focus)
function ChatEdit_DeactivateChat()
    if ChatFrame1EditBox and ChatFrame1EditBox.scripts and ChatFrame1EditBox.scripts["OnDeactivate"] then
        ChatFrame1EditBox.scripts["OnDeactivate"](ChatFrame1EditBox)
    end
end

-- Simulate sending text from the chat edit box.
function ChatEdit_SendText(editBox, send)
    print("ChatEdit_SendText:", editBox:GetText())
end

-----------------------------------------
-- CreateFrame Stub (with many extra methods)
-----------------------------------------
function CreateFrame(frameType, name, parent, template)
    local frame = {}
    frame.type = frameType
    frame.name = name or "MockFrame"
    frame.parent = parent
    frame.template = template
    frame.children = {}
    frame.scripts = {}
    frame.shown = false
    frame.width = 0
    frame.height = 0
    frame.alpha = 1
    frame.text = ""
    frame.cursorPos = 0
    frame.points = {}

    if name then
        _G[name] = frame
    end

    -- Provide a SetScale method.
    function frame:SetScale(scale)
        self.scale = scale
    end

    -- Extra stubs for scroll frames and related methods.
    if frameType == "ScrollFrame" then
        function frame:SetScrollChild(child)
            self.child = child
        end
        function frame:GetScrollChild()
            return self.child
        end
        function frame:SetVerticalScroll(offset)
            self.verticalScroll = offset
        end
        function frame:GetVerticalScroll()
            return self.verticalScroll or 0
        end
        function frame:SetHorizontalScroll(offset)
            self.horizontalScroll = offset
        end
        function frame:GetHorizontalScroll()
            return self.horizontalScroll or 0
        end
    end

    -- Basic methods.
    function frame:SetPoint(point, a1, a2, a3, a4)
        if type(a1) == "number" then
            self.points = { point, nil, nil, a1, a2 }
        else
            local relativeTo = a1 and a1.name or nil
            self.points = { point, relativeTo, a2, a3, a4 }
        end
    end

    function frame:SetSize(w, h)
        self.width = w
        self.height = h
    end
    function frame:GetWidth() return self.width end
    function frame:GetHeight() return self.height end
    function frame:Show() self.shown = true end
    function frame:Hide() self.shown = false end
    function frame:IsShown() return self.shown end
    function frame:IsVisible() return self.shown end
    function frame:EnableMouse(b) self.mouseEnabled = b end
    function frame:SetMovable(b) self.movable = b end
    function frame:RegisterForDrag(...) self.dragEvents = {...} end
    function frame:SetBackdrop(bdrop) self.backdrop = bdrop end
    function frame:SetBackdropColor(r, g, b, a) self.backdropColor = {r, g, b, a} end
    function frame:SetAlpha(a) self.alpha = a end
    function frame:SetText(t) self.text = t end
    function frame:GetText() return self.text or "" end
    function frame:SetCursorPosition(pos) self.cursorPos = pos end
    function frame:SetPropagateKeyboardInput(b) self.propagateKeyboard = b end
    function frame:StartMoving() self.isMoving = true end
    function frame:StopMovingOrSizing() self.isMoving = false end

    -- Script handling.
    function frame:SetScript(event, func) self.scripts[event] = func end
    function frame:GetScript(event) return self.scripts[event] end
    function frame:HookScript(event, func) self.scripts[event] = func end

    -- Event registration.
    frame.registeredEvents = {}
    function frame:RegisterEvent(evt) self.registeredEvents[evt] = true end
    function frame:UnregisterEvent(evt) self.registeredEvents[evt] = nil end

    -- Children handling.
    function frame:GetChildren() return self.children end
    function frame:SetParent(p)
        self.parent = p
        if p and p.children then
            table.insert(p.children, self)
        end
    end
    function frame:GetParent() return self.parent end

    -- If using a basic frame template, add TitleText and CloseButton.
    if template and template:find("BasicFrameTemplate") then
        frame.TitleText = { text = "", SetText = function(self, txt) self.text = txt end, GetText = function(self) return self.text or "" end }
    end
    if template and template:find("InterfaceOptionsCheckButtonTemplate") then
        frame.SetChecked = function(self, val)
            self.checkedState = (val == true)
        end
        frame.GetChecked = function(self)
            return self.checkedState == true
        end
        frame.Text = { text = "", SetText = function(self, txt) self.text = txt end }
    end
    if template and template:find("UIPanelButtonTemplate") then
        frame.Text = { text = "", SetText = function(self, txt) self.text = txt end }
    end

    -- FontString creation stub.
    function frame:CreateFontString(n, layer, templ)
        local fs = {}
        fs.text = ""
        function fs:SetText(txt) self.text = txt end
        function fs:GetText() return self.text or "" end
        function fs:SetPoint(...) end
        function fs:SetWidth(w) end
        function fs:SetJustifyH(justify) end
        return fs
    end

    -- Texture creation stub.
    function frame:CreateTexture(n, layer, templ)
        local tex = {}
        tex.hidden = false
        function tex:SetAllPoints(...) end
        function tex:SetPoint(...) end
        function tex:SetTexture(texture) self.texture = texture end
        function tex:SetAlpha(a) self.alpha = a end
        function tex:SetRotation(angle) self.rotation = angle end
        function tex:SetSize(w, h) self.width = w; self.height = h end
        function tex:SetColorTexture(r, g, b, a) self.color = {r, g, b, a} end
        function tex:Show() self.hidden = false end
        function tex:Hide() self.hidden = true end
        function tex:IsShown() return not self.hidden end
        return tex
    end

    return frame
end

-----------------------------------------
-- Global UI and Chat Stubs
-----------------------------------------
UIParent = UIParent or CreateFrame("Frame", "UIParent")
ChatFrame1 = ChatFrame1 or CreateFrame("Frame", "ChatFrame1", UIParent)
function ChatFrame1:Clear() end
function ChatFrame1:IsVisible() return true end
function ChatFrame1:AddMessage(msg) print("[ChatFrame1]:", msg) end

ChatFrame1EditBox = ChatFrame1EditBox or CreateFrame("Frame", "ChatFrame1EditBox", UIParent)
ChatFrame1EditBox.text = ""
function ChatFrame1EditBox:SetText(t) self.text = t end
function ChatFrame1EditBox:GetText() return self.text or "" end
function ChatFrame1EditBox:SetCursorPosition(p) self.cursorPos = p end
function ChatFrame1EditBox:HookScript(event, func)
    self.scripts = self.scripts or {}
    self.scripts[event] = func
end

NUM_CHAT_WINDOWS = NUM_CHAT_WINDOWS or 1

-----------------------------------------
-- Binding, Key, and Modifier Stubs
-----------------------------------------
GetNumBindings = GetNumBindings or function() return 0 end
GetBinding = GetBinding or function(i) return nil, nil, nil end
SetOverrideBindingClick = SetOverrideBindingClick or function(owner, isPriority, key, button) end
ClearOverrideBindings = ClearOverrideBindings or function(owner) end
hooksecurefunc = hooksecurefunc or function(name, func) end

IsShiftKeyDown = IsShiftKeyDown or function() return false end
IsControlKeyDown = IsControlKeyDown or function() return false end
InCombatLockdown = InCombatLockdown or function() return false end

-----------------------------------------
-- Macro and Slash API Stubs
-----------------------------------------
GetNumMacros = GetNumMacros or function() return 2, 2 end
GetMacroInfo = GetMacroInfo or function(i)
    if i == 1 then return "testmacro", "icon1", "/say Hello" end
    if i == 2 then return "WORLD", "icon2", "/wave" end
    return nil
end

SlashCmdList = SlashCmdList or {}
SLASH_COMMANDSAGE1 = SLASH_COMMANDSAGE1 or "/cmdsage"
SlashCmdList["COMMANDSAGE"] = SlashCmdList["COMMANDSAGE"] or function(msg) end
SLASH_COMMANDSAGEHISTORY1 = SLASH_COMMANDSAGEHISTORY1 or "/cmdsagehistory"
SlashCmdList["COMMANDSAGEHISTORY"] = SlashCmdList["COMMANDSAGEHISTORY"] or function(msg) end
SLASH_SEARCHHISTORY1 = SLASH_SEARCHHISTORY1 or "/searchhistory"
SlashCmdList["SEARCHHISTORY"] = SlashCmdList["SEARCHHISTORY"] or function(msg) end
SLASH_CLEARHISTORY1 = SLASH_CLEARHISTORY1 or "/clearhistory"
SlashCmdList["CLEARHISTORY"] = SlashCmdList["CLEARHISTORY"] or function(msg) end

-----------------------------------------
-- Friend List and Social Stubs
-----------------------------------------
C_FriendList = C_FriendList or {
    GetNumFriends = function() return 0 end,
    GetFriendInfoByIndex = function(i) return nil end
}

-----------------------------------------
-- World and Environment Stubs
-----------------------------------------
GetRealZoneText = GetRealZoneText or function() return "Stormwind" end
GetSubZoneText = GetSubZoneText or function() return "Trade District" end
WorldFrame = WorldFrame or {}

-----------------------------------------
-- Global String Utilities
-----------------------------------------
if not string.trim then
    function string:trim() return self:match("^%s*(.-)%s*$") end
end

-----------------------------------------
-- Voice Chat / TTS Stubs
-----------------------------------------
C_VoiceChat = C_VoiceChat or {}
if not C_VoiceChat.SpeakText then
    function C_VoiceChat.SpeakText(text, dest, rate, vol)
        print("C_VoiceChat.SpeakText called:", text)
    end
end
Enum = Enum or {}
Enum.VoiceTtsDestination = Enum.VoiceTtsDestination or { LocalPlayback = 0 }

-----------------------------------------
-- Chat Message Functions
-----------------------------------------
function ChatEdit_SendText(editBox, send)
    print("ChatEdit_SendText:", editBox:GetText())
end

-----------------------------------------
-- Additional Chat EditBox Methods
-----------------------------------------
function ChatFrame1EditBox:SetBackdropColor(r, g, b, a)
    self.backdropColor = {r, g, b, a}
end

-----------------------------------------
-- Extra WoW API Stubs (30+ new stubs)
-----------------------------------------
-- Stub for LibStub (commonly used by addons)
LibStub = LibStub or setmetatable({}, {
    __call = function(self, libName, version)
        -- Optionally, you can have some logic to return a stubbed version of the library.
        return {}  -- Return an empty table as the library stub.
    end
})


-- Stub for UnitName
UnitName = UnitName or function(unit)
    if unit == "player" then
        return "TestPlayer"
    end
    return "Unknown"
end

-- Stub for GetLocale
GetLocale = GetLocale or function()
    return "enUS"
end

-- Stub for PlaySound
PlaySound = PlaySound or function(soundID, channel)
    print("PlaySound called with soundID:", soundID)
end

-- Stub for StopSound
StopSound = StopSound or function(soundID)
    print("StopSound called with soundID:", soundID)
end

-- Stubs for SetCVar and GetCVar
SetCVar = SetCVar or function(cvar, value)
    _G[cvar] = value
end
GetCVar = GetCVar or function(cvar)
    return _G[cvar]
end

-- Stub for CreateAnimationGroup and CreateAnimation
function CreateAnimationGroup(frame)
    local ag = {}
    ag.animations = {}
    function ag:CreateAnimation(animType)
        local anim = { type = animType }
        table.insert(ag.animations, anim)
        return anim
    end
    function ag:Play() end
    return ag
end

-- Frame level stubs
function SetFrameLevel(frame, level)
    frame.frameLevel = level
end
function GetFrameLevel(frame)
    return frame.frameLevel or 1
end
function RaiseFrameLevel(frame)
    frame.frameLevel = (frame.frameLevel or 1) + 1
end
function LowerFrameLevel(frame)
    frame.frameLevel = (frame.frameLevel or 1) - 1
end

-- Addon messaging stubs
function RegisterAddonMessagePrefix(prefix)
    print("RegisterAddonMessagePrefix:", prefix)
end
function SendAddonMessage(prefix, message, channel, target)
    print("SendAddonMessage:", prefix, message, channel, target)
end

-- Stub for ToggleDropDownMenu (common in UI)
function ToggleDropDownMenu(level, value, dropdown, anchor, xOffset, yOffset)
    print("ToggleDropDownMenu called with level:", level)
end
-- Stub for CloseDropDownMenus
function CloseDropDownMenus(level)
    print("CloseDropDownMenus called with level:", level)
end

-- Cursor functions
function GetCursorPosition()
    return 100, 100
end
function SetCursorPosition(x, y)
    print("SetCursorPosition called:", x, y)
end

-- Stub for GameTooltip (basic implementation)
GameTooltip = GameTooltip or {}
function GameTooltip:SetOwner(owner, anchor)
    -- No-op for testing.
end
function GameTooltip:SetText(text, ...)
    print("GameTooltip:", text)
end
function GameTooltip:Hide()
    -- No-op for testing.
end

-- Debug print stub (for consistency)
function printDebug(msg)
    print("[Debug]:", msg)
end

-- Additional stub for IsAddOnLoaded
function IsAddOnLoaded(addonName)
    return true
end

-- Stub for ReloadUI
function ReloadUI()
    print("ReloadUI called")
end

-- Stub for PlayMusic
function PlayMusic(file)
    print("PlayMusic:", file)
end
-- Stub for StopMusic
function StopMusic()
    print("StopMusic called")
end

-- Stub for GetBindingKey
function GetBindingKey(command)
    return "CTRL-SHIFT-" .. command
end

-- Stub for ShowUIPanel
function ShowUIPanel(frame)
    frame:Show()
end
-- Stub for HideUIPanel
function HideUIPanel(frame)
    frame:Hide()
end
-- Stub for CloseMenus
function CloseMenus()
    print("CloseMenus called")
end

-----------------------------------------
-- End of wow_mock.lua
-----------------------------------------
print("wow_mock.lua: done setting up the environment.")
