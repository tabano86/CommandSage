-- tests/mocks.lua
-- Minimal WoW API stubs for offline testing in Windows/etc. Enforced first.

_G = _G or {}
SlashCmdList = {}
BINDING_HEADER = {}

function CreateFrame(frameType, name, parent, template)
    -- Return a table simulating a WoW UI Frame
    return {
        SetScript = function() end,
        RegisterEvent = function() end,
        HookScript = function() end,
        IsShown = function() return false end,
        Show = function() end,
        Hide = function() end,
        SetSize = function() end,
        SetPoint = function() end,
        EnableMouse = function() end,
        SetMovable = function() end,
        RegisterForDrag = function() end,
        SetBackdrop = function() end,
        SetBackdropColor = function() end,
        SetAlpha = function() end,
        SetText = function() end,
        SetCursorPosition = function() end,
        GetText = function() return "" end,
        SetPropagateKeyboardInput = function() end,
        Name = name or "MockFrame",
    }
end

UIParent = CreateFrame("Frame", "UIParent")
ChatFrame1 = CreateFrame("Frame", "ChatFrame1")
ChatFrame1EditBox = CreateFrame("Frame", "ChatFrame1EditBox")

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
    -- comment out if you want to see all prints during tests
    -- local txt = table.concat({...}, " ")
    -- io.stdout:write(txt .. "\n")
end

C_Timer = { After = function(sec, func) end }

-- No Ace loaded by default
LibStub = function(...) return nil end

-- For fallback scanning
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
