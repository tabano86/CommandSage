print("wow_mock.lua loaded (enhanced).")

if _G.__COMMANDSAGE_MOCK_LOADED then
    return
end
_G.__COMMANDSAGE_MOCK_LOADED = true

-- Provide `wipe`
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
        print("ChatEdit_SendText:", editBox:GetText())
    end
end

-- Provide global SlashCmdList
SlashCmdList = SlashCmdList or {}

SLASH_HELP1 = SLASH_HELP1 or "/help"
SlashCmdList["HELP"] = SlashCmdList["HELP"] or function(msg)
    print("HELP command used:", msg)
end

-- Provide C_Timer
C_Timer = C_Timer or {}
if not C_Timer.After then
    function C_Timer.After(delay, func)
        -- Immediately call for testing
        func()
    end
end

-- Frame creation stubs
local function createFontString()
    local fs = {}
    fs.text = ""
    function fs:SetText(txt) self.text = txt end
    function fs:GetText() return self.text end
    function fs:SetWidth(w) end
    function fs:SetPoint(...) end
    function fs:SetJustifyH(...) end
    return fs
end
local function createTexture()
    local t = {}
    function t:SetAllPoints(...) end
    function t:SetTexture(...) end
    function t:SetAlpha(...) end
    function t:SetRotation(...) end
    function t:SetSize(...) end
    function t:SetColorTexture(...) end
    function t:Show() self.hidden=false end
    function t:Hide() self.hidden=true end
    return t
end

if not CreateFrame then
    function CreateFrame(frameType, name, parent, template)
        local f = {}
        f.type = frameType
        f.name = name or ("MockFrame_"..tostring(math.random(999999)))
        f.parent = parent
        f.template = template
        f.children = {}
        f.scripts = {}
        f.shown = false
        f.width = 0
        f.height = 0
        f.alpha = 1

        -- Register to _G if we have a name
        if name then
            _G[name] = f
        end

        function f:SetPoint(...) end
        function f:SetSize(w,h)
            self.width = w
            self.height = h
        end
        function f:GetWidth() return self.width end
        function f:GetHeight() return self.height end
        function f:Show() self.shown = true end
        function f:Hide() self.shown = false end
        function f:IsShown() return self.shown end
        function f:IsVisible() return self.shown end
        function f:EnableMouse(...) end
        function f:SetMovable(...) end
        function f:RegisterForDrag(...) end
        function f:SetBackdrop(...) end
        function f:SetBackdropColor(r,g,b,a) end
        function f:SetAlpha(a) self.alpha = a end
        function f:SetText(t) self.text = t end
        function f:GetText() return self.text or "" end
        function f:SetCursorPosition(pos) self.cursorPos = pos end
        function f:SetPropagateKeyboardInput(...) end
        function f:StartMoving(...) end
        function f:StopMovingOrSizing(...) end

        function f:SetScript(evt, handler)
            self.scripts[evt] = handler
        end
        function f:GetScript(evt)
            return self.scripts[evt]
        end
        function f:HookScript(evt, handler)
            self.scripts[evt] = handler
        end

        f.registeredEvents = {}
        function f:RegisterEvent(e) self.registeredEvents[e] = true end
        function f:UnregisterEvent(e) self.registeredEvents[e] = nil end

        function f:GetChildren() return self.children end
        function f:SetParent(p)
            self.parent = p
            if p and p.children then
                table.insert(p.children, self)
            end
        end
        function f:GetParent() return self.parent end

        if template and template:find("BasicFrameTemplate") then
            f.TitleText = createFontString()
            -- Some templates might also have a CloseButton
            f.CloseButton = {
                SetScript = function(self, event, func) end,
                Hide = function() end,
                Show = function() end
            }
        end

        function f:CreateFontString(n, layer, templ)
            return createFontString()
        end
        function f:CreateTexture(n, layer, templ)
            return createTexture()
        end

        return f
    end
end

UIParent = UIParent or CreateFrame("Frame","UIParent")
ChatFrame1 = ChatFrame1 or CreateFrame("Frame","ChatFrame1", UIParent)
function ChatFrame1:Clear() end
function ChatFrame1:IsVisible() return true end
function ChatFrame1:AddMessage(msg) print("[ChatFrame1]:", msg) end

ChatFrame1EditBox = ChatFrame1EditBox or CreateFrame("Frame","ChatFrame1EditBox", UIParent)
ChatFrame1EditBox.text = ""
function ChatFrame1EditBox:SetText(t) self.text=t end
function ChatFrame1EditBox:GetText() return self.text or "" end
function ChatFrame1EditBox:SetCursorPosition(p) self.cursorPos=p end
function ChatFrame1EditBox:HookScript(evt,func)
    self.scripts = self.scripts or {}
    self.scripts[evt] = func
end

NUM_CHAT_WINDOWS = NUM_CHAT_WINDOWS or 1

GetNumBindings = GetNumBindings or function() return 0 end
GetBinding = GetBinding or function(...) return nil,nil,nil end
SetOverrideBindingClick = SetOverrideBindingClick or function(...) end
ClearOverrideBindings = ClearOverrideBindings or function(...) end
hooksecurefunc = hooksecurefunc or function(...) end
ChatEdit_DeactivateChat = ChatEdit_DeactivateChat or function(...) end

IsShiftKeyDown = IsShiftKeyDown or function() return false end
IsControlKeyDown = IsControlKeyDown or function() return false end
InCombatLockdown = InCombatLockdown or function() return false end

date = date or function(fmt) return "12:34:56" end
collectgarbage = collectgarbage or function(...) return 12345 end

GetNumMacros = GetNumMacros or function() return 2,2 end
GetMacroInfo = GetMacroInfo or function(i)
    if i == 1 then return "TESTMACRO","icon1","/say Hello"
    elseif i == 2 then return "WORLD","icon2","/wave" end
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

C_FriendList = C_FriendList or {
    GetNumFriends = function() return 0 end,
    GetFriendInfoByIndex = function(i) return nil end
}

GetRealZoneText = GetRealZoneText or function() return "Stormwind" end
GetSubZoneText = GetSubZoneText or function() return "Trade District" end
WorldFrame = WorldFrame or {}

if not string.trim then
    function string:trim()
        return self:match("^%s*(.-)%s*$")
    end
end

C_VoiceChat = C_VoiceChat or {}
if not C_VoiceChat.SpeakText then
    function C_VoiceChat.SpeakText(txt, dest, rate, vol)
        print("C_VoiceChat.SpeakText called:", txt)
    end
end
Enum = Enum or {}
Enum.VoiceTtsDestination = Enum.VoiceTtsDestination or { LocalPlayback=0 }

print("wow_mock.lua: done setting up the environment.")
