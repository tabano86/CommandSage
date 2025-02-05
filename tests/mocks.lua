-- tests/mocks.lua
_G = _G or {}

-- Provide a place for slash commands
SlashCmdList = SlashCmdList or {}
-- Provide example slash global definitions if needed
SLASH_HELP1 = "/help"
SlashCmdList["HELP"] = function(msg) end

-- Provide placeholders for the standard UIParent, ChatFrame1, EditBox, etc.
UIParent = UIParent or {}
ChatFrame1 = ChatFrame1 or {
    AddMessage = function(self, msg) end,
    Clear = function(self) end,
    IsVisible = function() return true end,
}
ChatFrame1EditBox = ChatFrame1EditBox or {
    text = "",
    SetText = function(self, txt) self.text = txt end,
    GetText = function(self) return self.text end,
    SetCursorPosition = function(self, pos) end,
    SetPropagateKeyboardInput = function(self, b) end,
    HookScript = function(...) end
}

NUM_CHAT_WINDOWS = 1

function CreateFrame(frameType, name, parent, template)
    local f = {}
    f.name = name or "MockFrame"
    f.frameType = frameType
    f.template = template
    f.scripts = {}
    f.hidden = true
    function f:Show() self.hidden = false end
    function f:Hide() self.hidden = true end
    function f:IsShown() return not self.hidden end
    function f:SetScript(event, func)
        self.scripts[event] = func
    end
    function f:GetScript(event)
        return self.scripts[event]
    end
    function f:RegisterEvent(e) end
    function f:SetSize(w,h) end
    function f:SetPoint(...) end
    function f:EnableMouse(b) end
    function f:SetMovable(b) end
    function f:RegisterForDrag(...) end
    function f:CreateFontString(...)
        local fs = {}
        function fs:SetText(t) self.text = t end
        function fs:SetPoint(...) end
        return fs
    end
    function f:SetBackdrop(...) end
    function f:SetBackdropColor(...) end
    function f:SetAlpha(a) self.alpha = a end

    -- If it’s an InterfaceOptionsCheckButtonTemplate, define a .Text field:
    if frameType=="CheckButton" and template=="InterfaceOptionsCheckButtonTemplate" then
        f.Text = f:CreateFontString(nil, "OVERLAY")
        function f.Text:SetText(t)
            self.text = t
        end
    end

    return f
end

-- Provide stubs for override bindings
function SetOverrideBindingClick(owner, isPriority, key, command)
    -- do nothing, or record in a table
end
function ClearOverrideBindings(owner) end

function hooksecurefunc(funcName, hookFunc)
    -- no-op
end

function ChatEdit_DeactivateChat(...) end

function IsShiftKeyDown() return false end
function IsControlKeyDown() return false end
function InCombatLockdown() return false end

function GetNumBindings() return 0 end
function GetBinding(i) return nil,nil,nil end

function print(...)
    -- Optionally pass, or store if you want
    local msg = table.concat({...}, " ")
    -- io.stdout:write(msg.."\n") -- optional
end

C_Timer = {
    After = function(sec, func)
        -- immediate or do nothing
    end
}

-- Provide a fallback slash for test
SLASH_COMMANDSAGEHISTORY1 = "/cmdsagehistory"
SlashCmdList["COMMANDSAGEHISTORY"] = function(msg) end
SLASH_SEARCHHISTORY1 = "/searchhistory"
SlashCmdList["SEARCHHISTORY"] = function(msg) end
SLASH_CLEARHISTORY1 = "/clearhistory"
SlashCmdList["CLEARHISTORY"] = function(msg) end

_G["SLASH_COMMANDSAGE1"] = "/cmdsage"
SlashCmdList["COMMANDSAGE"] = function(msg)
    -- basic commands
end

_G["SLASH_COMMANDSAGEHISTORY1"] = "/cmdsagehistory"
SlashCmdList["COMMANDSAGEHISTORY"] = function(msg) end

-- etc. (Add more if needed)

-- Provide a minimal friend list
C_FriendList = {
    GetNumFriends = function() return 0 end,
    GetFriendInfoByIndex = function(i) return nil end
}

-- For History Playback, we might do:
_G["SLASH_COMMANDSAGEHISTORY1"] = "/cmdsagehistory"
SlashCmdList["COMMANDSAGEHISTORY"] = function(msg) end

function GetNumMacros() return 2,2 end
function GetMacroInfo(i)
    if i==1 then return "TESTMACRO","icon1","/say Hello" end
    if i==2 then return "WORLD","icon2","/wave" end
    return nil
end

function date(fmt) return "12:34:56" end
function collectgarbage(...) return 12345 end

-- etc...
