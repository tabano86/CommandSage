-- tests/wow_mock.lua
-- Comprehensive WoW API Mock for CommandSage Tests

--------------------------------------------------------------------------------
-- Utility & Global Helpers
--------------------------------------------------------------------------------

if not LibStub or type(LibStub) ~= "function" then
    function LibStub(libName, strict)
        return {}
    end
end


-- Provide wipe if not already defined
if not wipe then
    function wipe(tbl)
        for k in pairs(tbl) do
            tbl[k] = nil
        end
        return tbl
    end
end

-- Provide UIFrameFadeIn
if not UIFrameFadeIn then
    function UIFrameFadeIn(frame, duration, fromAlpha, toAlpha)
        -- In WoW, this fades over time, but here we instantly set alpha.
        if frame and frame.SetAlpha then
            frame:SetAlpha(toAlpha)
        end
    end
end

-- Provide securecall
if not securecall then
    function securecall(func, ...)
        local ok, err = pcall(func, ...)
        if not ok then
            print("securecall error:", err)
        end
        return err
    end
end

-- Provide ChatEdit_SendText
if not ChatEdit_SendText then
    function ChatEdit_SendText(editBox, send)
        -- Usually sends text in the real client. For test, just print:
        print("ChatEdit_SendText:", editBox:GetText())
    end
end

--------------------------------------------------------------------------------
-- Global SlashCmdList
--------------------------------------------------------------------------------
SlashCmdList = SlashCmdList or {}
-- If needed, define a few slash commands to prevent "index a nil value"
SLASH_HELP1 = SLASH_HELP1 or "/help"
SlashCmdList["HELP"] = SlashCmdList["HELP"] or function(msg)
    print("HELP command used:", msg)
end

--------------------------------------------------------------------------------
-- C_Timer Stub
--------------------------------------------------------------------------------
C_Timer = C_Timer or {}
if not C_Timer.After then
    function C_Timer.After(delay, func)
        -- Immediately call it for testing
        func()
    end
end

--------------------------------------------------------------------------------
-- Frame Creation and Templates
--------------------------------------------------------------------------------
local function createFontString()
    local fs = {}
    fs.text = ""
    fs.SetText = function(self, txt)
        self.text = txt
    end
    fs.GetText = function(self)
        return self.text
    end
    fs.SetWidth = function(self, w)
    end
    fs.SetPoint = function(self, ...)
    end
    fs.SetJustifyH = function(self, j)
    end
    return fs
end

local function createTexture()
    local t = {}
    t.SetAllPoints = function(self, ...)
    end
    t.SetTexture = function(self, tex)
    end
    t.SetAlpha = function(self, alpha)
    end
    t.SetRotation = function(self, angle)
    end
    t.SetSize = function(self, w, h)
    end
    t.SetColorTexture = function(self, r, g, b, a)
    end
    t.Show = function(self)
        self.hidden = false
    end
    t.Hide = function(self)
        self.hidden = true
    end
    return t
end


if not CreateFrame then
    function CreateFrame(frameType, name, parent, template)
        local f = {}
        f.type = frameType
        f.name = name or "MockFrame"
        f.parent = parent
        f.template = template
        f.children = {}
        f.scripts = {}
        f.shown = false
        f.width = 0
        f.height = 0
        f.alpha = 1

        if name then
            _G[name] = f
        end

        -- Basic methods
        function f:SetPoint(...)
            -- Method stub.
        end
        function f:SetSize(w, h)
            self.width = w
            self.height = h
        end
        function f:GetWidth()
            return self.width
        end
        function f:GetHeight()
            return self.height
        end
        function f:Show()
            self.shown = true
        end
        function f:Hide()
            self.shown = false
        end
        function f:IsShown()
            return self.shown
        end
        function f:IsVisible()
            return self.shown
        end
        function f:EnableMouse(b)
        end
        function f:SetMovable(b)
        end
        function f:RegisterForDrag(...)
        end
        function f:SetBackdrop(bdrop)
        end
        function f:SetBackdropColor(r, g, b, a)
        end
        function f:SetAlpha(a)
            self.alpha = a
        end
        function f:SetText(t)
            self.text = t
        end
        function f:GetText()
            return self.text or ""
        end
        function f:SetCursorPosition(pos)
            self.cursorPos = pos
        end
        function f:SetPropagateKeyboardInput(b)
        end
        function f:StartMoving()
        end
        function f:StopMovingOrSizing()
        end

        -- Script handling
        function f:SetScript(event, handler)
            self.scripts[event] = handler
        end
        function f:GetScript(event)
            return self.scripts[event]
        end
        function f:HookScript(event, handler)
            self.scripts[event] = handler
        end

        -- Event registration
        f.registeredEvents = {}
        function f:RegisterEvent(evt)
            self.registeredEvents[evt] = true
        end
        function f:UnregisterEvent(evt)
            self.registeredEvents[evt] = nil
        end

        -- Children
        function f:GetChildren()
            return self.children
        end

        function f:SetParent(p)
            self.parent = p
            if p and p.children then
                table.insert(p.children, self)
            end
        end
        function f:GetParent()
            return self.parent
        end

        -- For frames using "BasicFrameTemplate"
        if template and template:find("BasicFrameTemplate") then
            f.TitleText = createFontString()
        end

        -- FontString creation
        function f:CreateFontString(n, layer, template)
            return createFontString()
        end

        -- Texture creation
        function f:CreateTexture(n, layer, template)
            return createTexture()
        end

        return f
    end
end

--------------------------------------------------------------------------------
-- UIParent, ChatFrame1, ChatFrame1EditBox
--------------------------------------------------------------------------------
UIParent = UIParent or CreateFrame("Frame", "UIParent")
ChatFrame1 = ChatFrame1 or CreateFrame("Frame", "ChatFrame1", UIParent)
function ChatFrame1:Clear()
end
function ChatFrame1:IsVisible()
    return true
end
function ChatFrame1:AddMessage(msg)
    print("[ChatFrame1]:", msg)
end

ChatFrame1EditBox = ChatFrame1EditBox or CreateFrame("Frame", "ChatFrame1EditBox", UIParent)
ChatFrame1EditBox.text = ""
function ChatFrame1EditBox:SetText(t)
    self.text = t
end
function ChatFrame1EditBox:GetText()
    return self.text or ""
end
function ChatFrame1EditBox:SetCursorPosition(p)
    self.cursorPos = p
end
function ChatFrame1EditBox:HookScript(event, func)
    self.scripts = self.scripts or {}
    self.scripts[event] = func
end

NUM_CHAT_WINDOWS = NUM_CHAT_WINDOWS or 1

--------------------------------------------------------------------------------
-- Binding / Key Functions
--------------------------------------------------------------------------------
GetNumBindings = GetNumBindings or function()
    return 0
end
GetBinding = GetBinding or function(i)
    return nil, nil, nil
end
SetOverrideBindingClick = SetOverrideBindingClick or function(owner, isPriority, key, button)
    -- no-op or debug print
end
ClearOverrideBindings = ClearOverrideBindings or function(owner)
    -- no-op or debug print
end
hooksecurefunc = hooksecurefunc or function(name, func)
    -- no-op
end
ChatEdit_DeactivateChat = ChatEdit_DeactivateChat or function()
    -- no-op
end

--------------------------------------------------------------------------------
-- InCombatLockdown, Key Modifiers
--------------------------------------------------------------------------------
IsShiftKeyDown = IsShiftKeyDown or function()
    return false
end
IsControlKeyDown = IsControlKeyDown or function()
    return false
end
InCombatLockdown = InCombatLockdown or function()
    return false
end

--------------------------------------------------------------------------------
-- Date, GC
--------------------------------------------------------------------------------
date = date or function(fmt)
    return "12:34:56"
end
collectgarbage = collectgarbage or function(...)
    return 12345
end

--------------------------------------------------------------------------------
-- Macros
--------------------------------------------------------------------------------
GetNumMacros = GetNumMacros or function()
    return 2, 2
end
GetMacroInfo = GetMacroInfo or function(i)
    if i == 1 then
        return "TESTMACRO", "icon1", "/say Hello"
    elseif i == 2 then
        return "WORLD", "icon2", "/wave"
    end
    return nil
end

--------------------------------------------------------------------------------
-- SlashCmdList Stubs
--------------------------------------------------------------------------------
SlashCmdList = SlashCmdList or {}
SLASH_COMMANDSAGE1 = SLASH_COMMANDSAGE1 or "/cmdsage"
SlashCmdList["COMMANDSAGE"] = SlashCmdList["COMMANDSAGE"] or function(msg)
end

SLASH_COMMANDSAGEHISTORY1 = SLASH_COMMANDSAGEHISTORY1 or "/cmdsagehistory"
SlashCmdList["COMMANDSAGEHISTORY"] = SlashCmdList["COMMANDSAGEHISTORY"] or function(msg)
end

SLASH_SEARCHHISTORY1 = SLASH_SEARCHHISTORY1 or "/searchhistory"
SlashCmdList["SEARCHHISTORY"] = SlashCmdList["SEARCHHISTORY"] or function(msg)
end

SLASH_CLEARHISTORY1 = SLASH_CLEARHISTORY1 or "/clearhistory"
SlashCmdList["CLEARHISTORY"] = SlashCmdList["CLEARHISTORY"] or function(msg)
end

-- etc. for any other slash commands you know you need.

--------------------------------------------------------------------------------
-- Friends / Social
--------------------------------------------------------------------------------
C_FriendList = C_FriendList or {
    GetNumFriends = function()
        return 0
    end,
    GetFriendInfoByIndex = function(i)
        return nil
    end
}

--------------------------------------------------------------------------------
-- Zone / World
--------------------------------------------------------------------------------
GetRealZoneText = GetRealZoneText or function()
    return "Stormwind"
end
GetSubZoneText = GetSubZoneText or function()
    return "Trade District"
end
WorldFrame = WorldFrame or {}

--------------------------------------------------------------------------------
-- Emulate WoW's string trimming
--------------------------------------------------------------------------------
_G.trim = _G.trim or function(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

--------------------------------------------------------------------------------
-- Voice Chat / TTS
--------------------------------------------------------------------------------
if not C_VoiceChat then
    C_VoiceChat = {}
    function C_VoiceChat.SpeakText(text, dest, rate, volume)
        print("C_VoiceChat.SpeakText called:", text)
    end
end
Enum = Enum or {}
Enum.VoiceTtsDestination = Enum.VoiceTtsDestination or { LocalPlayback = 0 }

--------------------------------------------------------------------------------
-- LibStub (Ace stubs if needed)
--------------------------------------------------------------------------------
if not LibStub then
    LibStub = {}
    function LibStub:GetLibrary(libname, silent)
        return nil
    end
end

--------------------------------------------------------------------------------
-- That’s it!
--------------------------------------------------------------------------------
print("wow_mock.lua loaded (enhanced).")
