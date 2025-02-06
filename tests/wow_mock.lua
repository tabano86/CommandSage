-- tests/wow_mock.lua
-- Enhanced WoW Classic Mocks for Testing

-- wipe: Clear all keys from a table.
wipe = wipe or function(tbl)
    for k in pairs(tbl) do
        tbl[k] = nil
    end
end

-- Global CVars store
local cvars = {}

-- CreateFrame mock with event handling, parent/child support, and additional methods.
CreateFrame = CreateFrame or function(frameType, name, parent, template)
    local f = {}
    f.type = frameType
    f.name = name
    f.parent = parent
    f.template = template
    f.children = {}
    f.scripts = {}
    f.registeredEvents = {}

    -- Basic frame methods.
    function f:SetPoint(...)
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
    function f:EnableMouse(enable)
        self.mouseEnabled = enable
    end
    function f:SetMovable(movable)
        self.movable = movable
    end
    function f:RegisterForDrag(...)
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
        self.cursorPosition = pos
    end
    function f:SetPropagateKeyboardInput(propagate)
        self.propagateKeyboard = propagate
    end

    -- CreateFontString mock.
    function f:CreateFontString(name, layer, template)
        local s = {}
        s.name = name
        s.layer = layer
        s.template = template
        function s:SetPoint(...)
        end
        function s:SetWidth(w)
            s.width = w
        end
        function s:SetText(text)
            s.text = text
        end
        function s:SetJustifyH(justify)
            s.justifyH = justify
        end
        return s
    end

    -- CreateTexture mock.
    function f:CreateTexture(name, layer, template)
        local t = {}
        t.name = name
        t.layer = layer
        t.template = template
        function t:SetAllPoints(obj)
            t.allPoints = obj
        end
        function t:SetTexture(texture)
            t.texture = texture
        end
        function t:SetAlpha(alpha)
            t.alpha = alpha
        end
        function t:SetRotation(angle)
            t.rotation = angle
        end
        function t:SetSize(w, h)
            t.width = w;
            t.height = h
        end
        function t:SetColorTexture(r, g, b, a)
            t.color = { r, g, b, a }
        end
        function t:Hide()
            t.hidden = true
        end
        function t:Show()
            t.hidden = false
        end
        return t
    end

    -- Script handling.
    function f:SetScript(event, handler)
        self.scripts[event] = handler
    end
    function f:GetScript(event)
        return self.scripts[event]
    end
    function f:FireEvent(event, ...)
        if self.scripts[event] then
            self.scripts[event](self, ...)
        end
    end

    -- Event registration.
    function f:RegisterEvent(event)
        self.registeredEvents[event] = true
    end
    function f:UnregisterEvent(event)
        self.registeredEvents[event] = nil
    end

    -- Parent-child relationships.
    function f:SetParent(parent)
        self.parent = parent
        if parent and parent.children then
            table.insert(parent.children, self)
        end
    end
    function f:GetParent()
        return self.parent
    end

    -- Frame strata.
    function f:SetFrameStrata(strata)
        self.strata = strata
    end
    function f:GetFrameStrata()
        return self.strata
    end

    -- Frame ID.
    function f:SetID(id)
        self.id = id
    end
    function f:GetID()
        return self.id
    end

    return f
end

-- Global UI elements.
SlashCmdList = SlashCmdList or {}
UIParent = UIParent or CreateFrame("Frame", "UIParent")
ChatFrame1 = ChatFrame1 or CreateFrame("Frame", "ChatFrame1")
function ChatFrame1:AddMessage(msg)
    print("ChatFrame1:", msg)
end
ChatFrame1EditBox = ChatFrame1EditBox or CreateFrame("Frame", "ChatFrame1EditBox")
function ChatFrame1EditBox:Insert(text)
    self.text = (self.text or "") .. text
end
NUM_CHAT_WINDOWS = NUM_CHAT_WINDOWS or 1

-- Input and combat mocks.
IsShiftKeyDown = IsShiftKeyDown or function()
    return false
end
IsControlKeyDown = IsControlKeyDown or function()
    return false
end
InCombatLockdown = InCombatLockdown or function()
    return false
end

-- Binding mocks.
GetNumBindings = GetNumBindings or function()
    return 0
end
GetBinding = GetBinding or function(i)
    return nil, nil, nil
end
SetOverrideBinding = SetOverrideBinding or function(...)
end
ClearOverrideBindings = ClearOverrideBindings or function(...)
end

-- Date and garbage collection mocks.
date = date or function(fmt)
    return "12:34:56"
end
collectgarbage = collectgarbage or function(...)
    return 12345
end

-- Macro mocks.
GetNumMacros = GetNumMacros or function()
    return 2, 2
end
GetMacroInfo = GetMacroInfo or function(i)
    if i == 1 then
        return "TESTMACRO", "icon1", "/say Hello"
    end
    if i == 2 then
        return "WORLD", "icon2", "/wave"
    end
    return nil
end

-- Hooking and chat editing.
hooksecurefunc = hooksecurefunc or function(...)
end
ChatEdit_DeactivateChat = ChatEdit_DeactivateChat or function(...)
end

-- Unit and player info mocks.
UnitName = UnitName or function(unit)
    return (unit == "player") and "MockPlayer" or "MockUnit"
end
UnitExists = UnitExists or function(unit)
    return unit == "player"
end
UnitHealth = UnitHealth or function(unit)
    return 100
end
UnitMana = UnitMana or function(unit)
    return 100
end
UnitClass = UnitClass or function(unit)
    return "Warrior", "WARRIOR"
end

-- Time and timer mocks.
GetTime = GetTime or function()
    return os.time()
end
C_Timer = C_Timer or {}
C_Timer.After = C_Timer.After or function(delay, func)
    -- Immediately execute callback for testing purposes.
    func()
end

-- String utilities.
_G.trim = _G.trim or function(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- Slash command help.
SLASH_HELP1 = SLASH_HELP1 or "/help"
SlashCmdList["HELP"] = SlashCmdList["HELP"] or function(...)
end

-- Friend list mocks.
C_FriendList = C_FriendList or {
    GetNumFriends = function()
        return 0
    end,
    GetFriendInfoByIndex = function(i)
        return nil
    end
}

-- Zone information mocks.
GetRealZoneText = GetRealZoneText or function()
    return "Stormwind"
end
GetSubZoneText = GetSubZoneText or function()
    return "Trade District"
end

-- World frame.
WorldFrame = WorldFrame or {}

-- Additional API mocks.

-- Item information.
GetItemInfo = GetItemInfo or function(itemID)
    return "Test Item", "INV_TEST_ITEM", 1, 100, 100, "Armor", "Test Slot", "Sell Price", "ItemLink"
end

-- Spell information.
GetSpellInfo = GetSpellInfo or function(spellID)
    return "Test Spell", "Spell_Test", 1, 100, 100, "Spell", "Test Range", "Spell Description"
end

-- CVar handling.
GetCVar = GetCVar or function(key)
    return cvars[key]
end
SetCVar = SetCVar or function(key, value)
    cvars[key] = value
end

-- Sound mocks.
PlaySound = PlaySound or function(sound)
    print("Playing sound:", sound)
end
StopSound = StopSound or function(sound)
    print("Stopping sound:", sound)
end

-- Popup mock.
StaticPopup_Show = StaticPopup_Show or function(name, text)
    print("StaticPopup_Show:", name, text)
end

-- Instance info (WoW Classic specific).
IsInInstance = IsInInstance or function()
    return false, "none"
end

-- Chat channel mocks.
JoinChannelByName = JoinChannelByName or function(channel)
    print("Joined channel:", channel)
end
LeaveChannelByName = LeaveChannelByName or function(channel)
    print("Left channel:", channel)
end

-- Debug print utility.
function DebugPrint(...)
    print("[DEBUG]", ...)
end

-- End of Enhanced WoW Classic Mocks
