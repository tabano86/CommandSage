--------------------------------------------------------------------------------
-- test_mini.lua
-- A single-file mini test runner for CommandSage with a mocked WoW environment.
-- No external frameworks needed.
--------------------------------------------------------------------------------

--------------------------------------
-- 1) Minimal Blizzard/Env Mocks
--------------------------------------
_G = _G or {}

-- We only mock the functions used in your code.
function CreateFrame(frameType, name, parent, template)
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
    }
end

function IsShiftKeyDown() return false end
function IsControlKeyDown() return false end
function InCombatLockdown() return false end

function wipe(t) for k,_ in pairs(t) do t[k] = nil end end
function print(...) -- so we don't spam console in tests
    -- local msg = table.concat({...}," ")
    -- io.write(msg.."\n")
end

SlashCmdList = {}
_G["SLASH_HELP1"] = "/help"
SlashCmdList["HELP"] = function(...) end

function GetNumMacros() return 2, 2 end
function GetMacroInfo(i)
    if i == 1 then return "TESTMACRO", nil, "/say Hello" end
    if i == 2 then return "WORLD", nil, "/wave" end
    return nil
end

NUM_CHAT_WINDOWS = 1
ChatFrame1EditBox = CreateFrame("Frame", "ChatFrame1EditBox")

function collectgarbage(...) return 12345 end
function date(fmt) return "12:34:56" end
function GetTime() return os.time() end

-- Minimal placeholders
function hooksecurefunc(...) end
function ChatEdit_DeactivateChat(...) end

-- Emulate global game tables
_G["ChatFrame1"] = CreateFrame("Frame", "ChatFrame1")
C_Timer = { After = function(sec, func) end }

--------------------------------------
-- 2) Load Your Actual Code
--------------------------------------
-- If your directories differ, adjust paths accordingly.
-- We'll assume we run from the 'CommandSage' root:
dofile("Core/CommandSage_Config.lua")
dofile("Modules/CommandSage_Trie.lua")

--------------------------------------
-- 3) A Simple Test Runner
--------------------------------------
local tests = {}  -- list of {name, fn}

local function it(testName, fn)
    table.insert(tests, {name = testName, fn = fn})
end

local function runTests()
    local passed, failed = 0, 0
    for _, testCase in ipairs(tests) do
        io.write("Running: ".. testCase.name .. " ... ")
        local ok, err = pcall(testCase.fn)
        if ok then
            print("OK")
            passed = passed + 1
        else
            print("FAIL\n   "..err)
            failed = failed + 1
        end
    end
    print(("Tests done. Passed=%d, Failed=%d"):format(passed, failed))
end

--------------------------------------
-- 4) TESTS for CommandSage_Config
--------------------------------------
it("Config initializes defaults", function()
    _G.CommandSageDB = {}
    CommandSage_Config:InitializeDefaults()
    assert(_G.CommandSageDB.config.preferences, "Expected preferences to be created")
    assert(_G.CommandSageDB.config.preferences.suggestionMode == "fuzzy", "Default mode should be 'fuzzy'")
end)

it("Config sets/gets preference values", function()
    _G.CommandSageDB = {}
    CommandSage_Config:InitializeDefaults()
    CommandSage_Config.Set("preferences", "uiTheme", "light")
    local val = CommandSage_Config.Get("preferences", "uiTheme")
    assert(val == "light", "Expected uiTheme to be 'light'")
end)

it("Config resets preferences", function()
    _G.CommandSageDB = {}
    CommandSage_Config:InitializeDefaults()
    CommandSage_Config.Set("preferences", "uiTheme", "light")
    assert(CommandSage_Config.Get("preferences", "uiTheme") == "light", "uiTheme wasn't set properly")

    CommandSage_Config:ResetPreferences()
    assert(CommandSage_Config.Get("preferences", "uiTheme") == "dark", "Expected default 'dark' after reset")
end)

--------------------------------------
-- 5) TESTS for CommandSage_Trie
--------------------------------------
it("Trie inserts and finds prefixes", function()
    CommandSage_Trie:Clear()
    CommandSage_Trie:InsertCommand("/dance", {desc="dance"})
    CommandSage_Trie:InsertCommand("/da", {desc="da"})

    local results = CommandSage_Trie:FindPrefix("/da")
    assert(#results >= 2, "Expected /dance and /da in results")
end)

it("Trie removes commands", function()
    CommandSage_Trie:Clear()
    CommandSage_Trie:InsertCommand("/macro", {desc="macro"})

    local found = CommandSage_Trie:FindPrefix("/macro")
    assert(#found == 1, "Should find /macro initially")

    CommandSage_Trie:RemoveCommand("/macro")
    local found2 = CommandSage_Trie:FindPrefix("/macro")
    assert(#found2 == 0, "Should not find /macro after removal")
end)

--------------------------------------
-- 6) Run them
--------------------------------------
runTests()
