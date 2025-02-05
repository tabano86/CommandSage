-- tests/mocks.lua
-- Minimal WoW API stubs for offline testing in Windows/etc. Enforced first.

_G = _G or {}
SlashCmdList = {}
BINDING_HEADER = {}

function CreateFrame(frameType, name, parent, template)
    local frame = {}
    frame.name = name or "MockFrame"
    frame.scripts = {}
    frame.text = ""
    frame.hidden = true
    frame.alpha = 1
    frame.SetScript = function(self, script, func)
        self.scripts[script] = func
    end
    frame.GetScript = function(self, script)
        return self.scripts[script]
    end
    frame.RegisterEvent = function() end
    frame.HookScript = function(self, script, func)
        local orig = self.scripts[script] or function() end
        self.scripts[script] = function(...)
            orig(...)
            func(...)
        end
    end
    frame.IsShown = function(self)
        return not self.hidden
    end
    frame.Show = function(self)
        self.hidden = false
    end
    frame.Hide = function(self)
        self.hidden = true
    end
    frame.SetSize = function() end
    frame.SetPoint = function() end
    frame.EnableMouse = function() end
    frame.SetMovable = function() end
    frame.RegisterForDrag = function() end
    frame.SetBackdrop = function() end
    frame.SetBackdropColor = function() end
    frame.SetAlpha = function(self, alpha)
        self.alpha = alpha
    end
    frame.GetAlpha = function(self)
        return self.alpha
    end
    frame.SetText = function(self, txt)
        self.text = txt
    end
    frame.GetText = function(self)
        return self.text
    end
    frame.SetCursorPosition = function(self, pos)
        self.cursorPos = pos
    end
    frame.SetPropagateKeyboardInput = function() end
    frame.CreateFontString = function(self, ...)
        local fontStr = {}
        fontStr.text = ""
        fontStr.SetPoint = function() end
        fontStr.SetWidth = function() end
        fontStr.SetText = function(self, txt)
            self.text = txt
        end
        fontStr.SetJustifyH = function() end
        return fontStr
    end
    frame.CreateTexture = function(self, ...)
        local tex = {}
        tex.SetAllPoints = function() end
        tex.SetTexture = function(self, texture) self.texture = texture end
        tex.SetAlpha = function(self, alpha) self.alpha = alpha end
        tex.SetRotation = function(self, rot) self.rotation = rot end
        tex.SetSize = function() end
        tex.SetColorTexture = function(self, r, g, b, a) self.color = {r, g, b, a} end
        tex.Hide = function(self) self.hidden = true end
        tex.Show = function(self) self.hidden = false end
        return tex
    end
    -- For frames using the BasicFrameTemplate, add a TitleText field:
    if template and template:find("BasicFrameTemplate") then
        frame.TitleText = {
            SetText = function(self, txt) self.text = txt end,
            text = ""
        }
    end
    return frame
end

UIParent = CreateFrame("Frame", "UIParent")
ChatFrame1 = CreateFrame("Frame", "ChatFrame1")
ChatFrame1EditBox = CreateFrame("Frame", "ChatFrame1EditBox")
-- Implement ChatFrame1EditBox to store text.
ChatFrame1EditBox.text = ""
ChatFrame1EditBox.SetText = function(self, txt) self.text = txt end
ChatFrame1EditBox.GetText = function(self) return self.text end
ChatFrame1EditBox.SetCursorPosition = function(self, pos) self.cursorPos = pos end

NUM_CHAT_WINDOWS = 1

function IsShiftKeyDown() return false end
function IsControlKeyDown() return false end
function InCombatLockdown() return false end
function GetBinding() return nil end
function SetOverrideBinding(...) end
function ClearOverrideBindings(...) end
function GetNumBindings() return 0 end

-- Minimal macro stubs
function GetNumMacros() return 2, 2 end
function GetMacroInfo(index)
    if index == 1 then return "TESTMACRO", "icon1", "/say Hello" end
    if index == 2 then return "WORLD", "icon2", "/wave" end
    if index == 3 then return "CHARMACRO", "icon3", "/dance" end
    if index == 4 then return "CHAR2", "icon4", "/hello" end
    return nil
end

function collectgarbage(...) return 12345 end

function wipe(t)
    for k,_ in pairs(t) do t[k] = nil end
end

-- Override print so tests won't spam your console
function print(...)
    -- Uncomment to see output:
    -- local txt = table.concat({...}, " ")
    -- io.stdout:write(txt .. "\n")
end

C_Timer = { After = function(sec, func) end }

LibStub = function(...) return nil end

SlashCmdList["HELP"] = function(...) end
_G["SLASH_HELP1"] = "/help"

function hooksecurefunc(funcName, hookFunc) end
function ChatEdit_DeactivateChat(...) end

SlashCmdList["COMBATLOG"] = function(...) end
_G["SLASH_COMBATLOG1"] = "/combatlog"

function date(fmt) return "12:34:56" end
function GetTime() return os.time() end
function _G.trim(s) return (s:gsub("^%s*(.-)%s*$", "%1")) end

_G["ChatFrame1EditBox"] = ChatFrame1EditBox

_G["SLASH_FAKEMODE1"] = "/fakemode"
SlashCmdList["FAKEMODE"] = function(...) end

GetRealZoneText = function() return "Stormwind" end
GetSubZoneText = function() return "Trade District" end

_G["UnitName"] = function() return "MockTester" end
