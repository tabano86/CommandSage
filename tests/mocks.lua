-- tests/mocks.lua
-- FIRST: Define globals that modules depend on

-- Define wipe if not already defined
if not wipe then
    wipe = function(tbl)
        for k in pairs(tbl) do
            tbl[k] = nil
        end
    end
end

-- Define CreateFrame before it is used anywhere else
function CreateFrame(frameType, name, parent, template)
    local f = {}
    f.name = name or "MockFrame"
    f.frameType = frameType
    f.template = template
    f.scripts = {}
    f.hidden = true
    f.children = {}
    -- Methods
    function f:Show()
        self.hidden = false
    end
    function f:Hide()
        self.hidden = true
    end
    function f:IsShown()
        return not self.hidden
    end
    function f:SetScript(event, func)
        self.scripts[event] = func
    end
    function f:GetScript(event)
        return self.scripts[event]
    end
    function f:RegisterEvent(e)
    end
    function f:SetSize(w, h)
        self.width = w
        self.height = h
    end
    function f:SetPoint(...)
    end
    function f:EnableMouse(b)
    end
    function f:SetMovable(b)
    end
    function f:RegisterForDrag(...)
    end
    function f:SetBackdrop(backdrop)
        self.backdrop = backdrop
    end
    function f:SetBackdropColor(...)
        self.backdropColor = { ... }
    end
    function f:SetAlpha(a)
        self.alpha = a
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

    -- Special handling for CheckButton template
    if frameType == "CheckButton" and template == "InterfaceOptionsCheckButtonTemplate" then
        f.Text = f:CreateFontString(nil, "OVERLAY")
        function f.Text:SetText(t)
            self.text = t
        end
        f.checked = false
        function f:GetChecked()
            return self.checked
        end
        function f:SetChecked(b)
            self.checked = b
        end
    end

    -- For frames using the BasicFrameTemplate, add TitleText
    if template and template:find("BasicFrameTemplate") then
        f.TitleText = f:CreateFontString(nil, "OVERLAY")
        function f.TitleText:SetText(t)
            self.text = t
        end
    end

    return f
end

-- Provide stubs for override binding functions
function SetOverrideBindingClick(owner, isPriority, key, command)
    -- For test purposes, do nothing
end
function ClearOverrideBindings(owner)
    -- For test purposes, do nothing
end

-- Minimal stub for hooksecurefunc
function hooksecurefunc(funcName, hookFunc)
    -- no-op stub; in tests we assume functions do not need to be hooked
end

function ChatEdit_DeactivateChat(...)
end

-- Input mocks
function IsShiftKeyDown()
    return false
end
function IsControlKeyDown()
    return false
end
function InCombatLockdown()
    return false
end

function GetNumBindings()
    return 0
end
function GetBinding(i)
    return nil, nil, nil
end

-- Override print to simply call the real print (or store output if needed)
local realPrint = print
function print(...)
    realPrint(...)
end

-- Provide a stub for C_Timer.After
C_Timer = C_Timer or {}
C_Timer.After = C_Timer.After or function(sec, func)
    -- For tests, simply call the function immediately
    func()
end

-- Stub for slash commands that may be defined later
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

-- Minimal friend list
C_FriendList = C_FriendList or {
    GetNumFriends = function()
        return 0
    end,
    GetFriendInfoByIndex = function(i)
        return nil
    end
}

-- Macro stubs
function GetNumMacros()
    return 2, 2
end
function GetMacroInfo(i)
    if i == 1 then
        return "TESTMACRO", "icon1", "/say Hello"
    end
    if i == 2 then
        return "WORLD", "icon2", "/wave"
    end
    return nil
end

-- Date and garbage collector
function date(fmt)
    return "12:34:56"
end
function collectgarbage(...)
    return 12345
end
