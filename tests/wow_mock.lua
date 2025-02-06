-----------------------------------------------------------
-- tests/wow_mock.lua
-- Comprehensive WoW API Mock File for Addon Testing
-- This file simulates a World of Warcraft environment and
-- includes support for:
--   • Frame creation (with support for basic templates)
--   • Event registration, hooking, and drag handling
--   • Timers, unit info, zone info, macros, friend lists, etc.
--   • Binding functions and secure calls
--   • Fading functions and other utilities
-- This mock is inspired by various Ace testing libraries and
-- community WoWMock projects, but it is enhanced to be as complete
-- as possible for testing add-ons like CommandSage.
-----------------------------------------------------------

-----------------------------------------------------------
-- Utility Functions
-----------------------------------------------------------
wipe = wipe or function(tbl)
    for k in pairs(tbl) do
        tbl[k] = nil
    end
    return tbl
end

-----------------------------------------------------------
-- Global CVars Store
-----------------------------------------------------------
local cvars = {}

-----------------------------------------------------------
-- Global Helper Functions & API Stubs
-----------------------------------------------------------
-- UIFrameFadeIn: For testing, immediately sets frame alpha.
UIFrameFadeIn = UIFrameFadeIn or function(frame, time, fromAlpha, toAlpha)
    if frame and frame.SetAlpha then
        frame:SetAlpha(toAlpha)
    end
end

-- securecall: Run a function in protected mode.
securecall = securecall or function(func, ...)
    local ok, result = pcall(func, ...)
    if not ok then
        print("securecall error:", result)
    end
    return result
end

-----------------------------------------------------------
-- CreateFrame Mock (Enhanced)
-----------------------------------------------------------
CreateFrame = CreateFrame or function(frameType, name, parent, template)
    local f = {}
    f.type = frameType
    f.name = name or "UnnamedFrame"
    f.parent = parent
    f.template = template
    f.children = {}
    f.scripts = {}
    f.registeredEvents = {}
    f.shown = false
    f.width = 0
    f.height = 0
    f.alpha = 1
    f.text = ""

    -- Basic frame methods
    function f:SetPoint(...) end

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
    f.IsVisible = f.IsShown

    function f:EnableMouse(enable)
        self.mouseEnabled = enable
    end

    function f:SetMovable(movable)
        self.movable = movable
    end

    function f:RegisterForDrag(...)
        self.dragEvents = { ... }
    end

    function f:SetBackdrop(backdrop)
        self.backdrop = backdrop
    end

    function f:SetBackdropColor(r, g, b, a)
        self.backdropColor = { r, g, b, a }
    end

    function f:SetAlpha(alpha)
        self.alpha = alpha
    end

    function f:SetText(text)
        self.text = text
    end

    function f:GetText()
        return self.text or ""
    end

    function f:SetCursorPosition(pos)
        self.cursorPos = pos
    end

    function f:SetPropagateKeyboardInput(propagate)
        self.propagateKeyboard = propagate
    end

    -- Dragging support
    function f:StartMoving()
        self.moving = true
    end

    function f:StopMovingOrSizing()
        self.moving = false
    end

    -- HookScript support
    function f:HookScript(event, handler)
        self.scripts = self.scripts or {}
        self.scripts[event] = handler
    end

    function f:GetScript(event)
        return (self.scripts and self.scripts[event]) or nil
    end

    -- GetChildren support
    function f:GetChildren()
        return self.children
    end

    -- Event registration
    function f:RegisterEvent(event)
        self.registeredEvents[event] = true
    end

    function f:UnregisterEvent(event)
        self.registeredEvents[event] = nil
    end

    -- Parent/child relationships
    function f:SetParent(parent)
        self.parent = parent
        if parent and parent.children then
            table.insert(parent.children, self)
        end
    end

    function f:GetParent()
        return self.parent
    end

    -- Frame strata and ID
    function f:SetFrameStrata(strata)
        self.strata = strata
    end

    function f:GetFrameStrata()
        return self.strata
    end

    function f:SetID(id)
        self.id = id
    end

    function f:GetID()
        return self.id
    end

    -- CreateFontString mock.
    function f:CreateFontString(fontName, layer, template)
        local s = {}
        s.name = fontName or "UnnamedFontString"
        s.layer = layer
        s.template = template
        function s:SetPoint(...) end
        function s:SetWidth(w) s.width = w end
        function s:SetText(text) s.text = text end
        function s:SetJustifyH(justify) s.justifyH = justify end
        return s
    end

    -- CreateTexture mock.
    function f:CreateTexture(texName, layer, template)
        local t = {}
        t.name = texName or "UnnamedTexture"
        t.layer = layer
        t.template = template
        function t:SetAllPoints(obj) t.allPoints = obj end
        function t:SetTexture(texture) t.texture = texture end
        function t:SetAlpha(alpha) t.alpha = alpha end
        function t:SetRotation(angle) t.rotation = angle end
        function t:SetSize(w, h) t.width = w; t.height = h end
        function t:SetColorTexture(r, g, b, a) t.color = { r, g, b, a } end
        function t:Hide() t.hidden = true end
        function t:Show() t.hidden = false end
        return t
    end

    -- Support for common templates
    if template then
        if template == "BasicFrameTemplate" then
            f.TitleText = f:CreateFontString("TitleText", "OVERLAY", "GameFontNormal")
            f.TitleText.text = (name and (name .. " Title")) or "Untitled"
        end
        if template == "UIPanelButtonTemplate" then
            f.type = "Button"
            f.text = ""
            function f:SetText(text)
                self.text = text
            end
            function f:GetText()
                return self.text or ""
            end
        end
        if template == "InterfaceOptionsCheckButtonTemplate" then
            f.type = "CheckButton"
            f.checked = false
            f.Text = f:CreateFontString("Text", "OVERLAY")
            function f:SetChecked(val)
                self.checked = val
            end
            function f:GetChecked()
                return self.checked
            end
        end
    end

    return f
end

-----------------------------------------------------------
-- Global UI Elements
-----------------------------------------------------------
SlashCmdList = SlashCmdList or {}
UIParent = UIParent or CreateFrame("Frame", "UIParent")
ChatFrame1 = ChatFrame1 or CreateFrame("Frame", "ChatFrame1")
function ChatFrame1:AddMessage(msg)
    print("ChatFrame1:", msg)
end
function ChatFrame1:Clear()
    self.text = ""
end

ChatFrame1EditBox = ChatFrame1EditBox or CreateFrame("Frame", "ChatFrame1EditBox")
function ChatFrame1EditBox:SetText(text)
    self.text = text
end
function ChatFrame1EditBox:GetText()
    return self.text or ""
end
function ChatFrame1EditBox:HookScript(event, handler)
    self.scripts = self.scripts or {}
    self.scripts[event] = handler
end
function ChatFrame1EditBox:SetCursorPosition(pos)
    self.cursorPos = pos
end
NUM_CHAT_WINDOWS = NUM_CHAT_WINDOWS or 1

-----------------------------------------------------------
-- Input and Combat Mocks
-----------------------------------------------------------
IsShiftKeyDown = IsShiftKeyDown or function() return false end
IsControlKeyDown = IsControlKeyDown or function() return false end
InCombatLockdown = InCombatLockdown or function() return false end

-----------------------------------------------------------
-- Binding Mocks
-----------------------------------------------------------
GetNumBindings = GetNumBindings or function() return 0 end
GetBinding = GetBinding or function(i) return nil, nil, nil end
SetOverrideBinding = SetOverrideBinding or function(...) end
ClearOverrideBindings = ClearOverrideBindings or function(owner)
    print("ClearOverrideBindings called for:", owner)
end
SetOverrideBindingClick = SetOverrideBindingClick or function(owner, isPriority, key, button)
    print("SetOverrideBindingClick:", owner, isPriority, key, button)
end

-----------------------------------------------------------
-- Date and Garbage Collection Mocks
-----------------------------------------------------------
date = date or function(fmt) return "12:34:56" end
collectgarbage = collectgarbage or function(...) return 12345 end

-----------------------------------------------------------
-- Macro Mocks
-----------------------------------------------------------
GetNumMacros = GetNumMacros or function() return 2, 2 end
GetMacroInfo = GetMacroInfo or function(i)
    if i == 1 then
        return "TESTMACRO", "icon1", "/say Hello"
    elseif i == 2 then
        return "WORLD", "icon2", "/wave"
    end
    return nil
end

-----------------------------------------------------------
-- Hooking and Chat Editing Mocks
-----------------------------------------------------------
hooksecurefunc = hooksecurefunc or function(funcName, hookFunc)
    print("hooksecurefunc: Hooking", funcName)
end
ChatEdit_DeactivateChat = ChatEdit_DeactivateChat or function()
    print("ChatEdit_DeactivateChat called")
end

-----------------------------------------------------------
-- Unit and Player Info Mocks
-----------------------------------------------------------
UnitName = UnitName or function(unit)
    return (unit == "player") and "MockPlayer" or "MockUnit"
end
UnitExists = UnitExists or function(unit) return unit == "player" end
UnitHealth = UnitHealth or function(unit) return 100 end
UnitMana = UnitMana or function(unit) return 100 end
UnitClass = UnitClass or function(unit) return "Warrior", "WARRIOR" end

-----------------------------------------------------------
-- Time and Timer Mocks
-----------------------------------------------------------
GetTime = GetTime or function() return os.time() end
C_Timer = C_Timer or {}
C_Timer.After = C_Timer.After or function(delay, func)
    func()
end

-----------------------------------------------------------
-- String Utilities
-----------------------------------------------------------
_G.trim = _G.trim or function(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-----------------------------------------------------------
-- Slash Command Help
-----------------------------------------------------------
SLASH_HELP1 = SLASH_HELP1 or "/help"
SlashCmdList["HELP"] = SlashCmdList["HELP"] or function(...)
    print("SlashCmdList[HELP] called with:", ...)
end

-----------------------------------------------------------
-- Friend List Mocks
-----------------------------------------------------------
C_FriendList = C_FriendList or {
    GetNumFriends = function() return 0 end,
    GetFriendInfoByIndex = function(i) return nil end
}

-----------------------------------------------------------
-- Zone Information Mocks
-----------------------------------------------------------
GetRealZoneText = GetRealZoneText or function() return "Stormwind" end
GetSubZoneText = GetSubZoneText or function() return "Trade District" end

-----------------------------------------------------------
-- World Frame
-----------------------------------------------------------
WorldFrame = WorldFrame or {}

-----------------------------------------------------------
-- Additional API Mocks
-----------------------------------------------------------
-- Item Information.
GetItemInfo = GetItemInfo or function(itemID)
    return "Test Item", "INV_TEST_ITEM", 1, 100, 100, "Armor", "Test Slot", "Sell Price", "ItemLink"
end

-- Spell Information.
GetSpellInfo = GetSpellInfo or function(spellID)
    return "Test Spell", "Spell_Test", 1, 100, 100, "Spell", "Test Range", "Spell Description"
end

-----------------------------------------------------------
-- CVar Handling
-----------------------------------------------------------
GetCVar = GetCVar or function(key) return cvars[key] end
SetCVar = SetCVar or function(key, value) cvars[key] = value end

-----------------------------------------------------------
-- Sound Mocks
-----------------------------------------------------------
PlaySound = PlaySound or function(sound)
    print("Playing sound:", sound)
end
StopSound = StopSound or function(sound)
    print("Stopping sound:", sound)
end

-----------------------------------------------------------
-- Popup Mocks
-----------------------------------------------------------
StaticPopup_Show = StaticPopup_Show or function(name, text)
    print("StaticPopup_Show:", name, text)
end

-----------------------------------------------------------
-- Instance Info (WoW Classic Specific)
-----------------------------------------------------------
IsInInstance = IsInInstance or function() return false, "none" end

-----------------------------------------------------------
-- Chat Channel Mocks
-----------------------------------------------------------
JoinChannelByName = JoinChannelByName or function(channel)
    print("Joined channel:", channel)
end
LeaveChannelByName = LeaveChannelByName or function(channel)
    print("Left channel:", channel)
end

-----------------------------------------------------------
-- Debug Print Utility
-----------------------------------------------------------
function DebugPrint(...)
    print("[DEBUG]", ...)
end

-----------------------------------------------------------
-- Future-Proofing & Additional Globals
-----------------------------------------------------------
if not wipe then
    wipe = function(tbl)
        for k in pairs(tbl) do
            tbl[k] = nil
        end
        return tbl
    end
end

-----------------------------------------------------------
-- End of Enhanced WoW Classic Mocks
-----------------------------------------------------------
