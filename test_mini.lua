--------------------------------------------------------------------------------
-- test_mini.lua
-- A single-file “mega” test runner for CommandSage with an expanded Blizzard
-- environment mock. No external frameworks required.
--------------------------------------------------------------------------------

-------------------------------------
-- 1) EXTENDED Blizzard/Env Mocks
-------------------------------------
_G = _G or {}

-- Fake slash command registration
SlashCmdList = {}
-- Typical references for "SLASH_<name>1" etc.
_G["SLASH_HELP1"] = "/help"
SlashCmdList["HELP"] = function(...) end

-- Basic print override to reduce spam (optional)
function print(...)
    -- Uncomment if you want to see all print output:
    -- local msg = table.concat({...}," ")
    -- io.write(msg.."\n")
end

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
        Name = name or "MockFrame",
        CreateTexture = function()
            return {
                SetAllPoints=function() end,
                SetTexture=function() end,
                SetAlpha=function() end,
            }
        end,
    }
end

function InCombatLockdown() return false end
function IsShiftKeyDown() return false end
function IsControlKeyDown() return false end

NUM_CHAT_WINDOWS = 1
ChatFrame1 = CreateFrame("Frame","ChatFrame1")
ChatFrame1EditBox = CreateFrame("Frame","ChatFrame1EditBox")
_G["ChatFrame1"] = ChatFrame1
_G["ChatFrame1EditBox"] = ChatFrame1EditBox

-- For scanning macros
function GetNumMacros() return 2,2 end
function GetMacroInfo(index)
    if index == 1 then return "TESTMACRO", nil, "/say Hello" end
    if index == 2 then return "WORLD", nil, "/wave" end
    return nil
end

function hooksecurefunc(...) end
function ChatEdit_DeactivateChat(...) end
function GetBinding(i) return nil,nil,nil end
function SetOverrideBinding(...) end
function ClearOverrideBindings(...) end
function GetNumBindings() return 0 end

-- Minimal
C_Timer = { After = function(sec, func) end }
function date(fmt) return "12:34:56" end
function GetTime() return os.time() end
function collectgarbage(...) return 12345 end
function wipe(t) for k,_ in pairs(t) do t[k]=nil end end

_G["SLASH_COMBATLOG1"] = "/combatlog"
SlashCmdList["COMBATLOG"] = function(...) end
-- For discovery scanning
_G["SLASH_FAKEMODE1"] = "/fakemode"
SlashCmdList["FAKEMODE"] = function(...) end

-- For C_FriendList stubs:
C_FriendList = {
    GetNumFriends = function() return 0 end,
    GetFriendInfoByIndex = function(i) return nil end
}

-- SubeZone stubs for /pwd
function GetRealZoneText() return "Stormwind" end
function GetSubZoneText() return "Trade District" end
function UnitName(target) return "MockTester" end

function _G.trim(s) return (s:gsub("^%s*(.-)%s*$", "%1")) end

-------------------------------------
-- 2) LOAD CommandSage Modules
-------------------------------------
-- Adjust these dofile paths if your structure differs:
dofile("Core/CommandSage_Config.lua")
dofile("Core/CommandSage_Core.lua")
dofile("Core/CommandSage_Discovery.lua")

dofile("Modules/CommandSage_Trie.lua")
dofile("Modules/CommandSage_FuzzyMatch.lua")
dofile("Modules/CommandSage_ParameterHelper.lua")
dofile("Modules/CommandSage_AdaptiveLearning.lua")
dofile("Modules/CommandSage_PersistentTrie.lua")
dofile("Modules/CommandSage_Tutorial.lua")
dofile("Modules/CommandSage_Performance.lua")
dofile("Modules/CommandSage_SecureCallback.lua")
dofile("Modules/CommandSage_Fallback.lua")
dofile("Modules/CommandSage_CommandOrganizer.lua")
dofile("Modules/CommandSage_AutoType.lua")
dofile("Modules/CommandSage_HistoryPlayback.lua")
dofile("Modules/CommandSage_DeveloperAPI.lua")
dofile("Modules/CommandSage_UIAccessibility.lua")
dofile("Modules/CommandSage_Analytics.lua")
dofile("Modules/CommandSage_MultiModal.lua")
dofile("Modules/CommandSage_AROverlays.lua")
dofile("Modules/CommandSage_AutoComplete.lua")
dofile("Modules/CommandSage_Terminal.lua")
dofile("Modules/CommandSage_ShellContext.lua")
dofile("Modules/CommandSage_Licensing.lua")
dofile("Modules/CommandSage_ConfigGUI.lua")
dofile("Modules/CommandSage_KeyBlocker.lua")

-------------------------------------
-- 3) A Simple Test Runner
-------------------------------------
local tests = {}
local function it(testName, fn)
    table.insert(tests, {name = testName, fn = fn})
end

local function runTests()
    local passed, failed = 0, 0
    print("\n=== Running CommandSage Tests ===")
    for _, testCase in ipairs(tests) do
        io.write("Test: ".. testCase.name .. " ... ")
        local ok, err = pcall(testCase.fn)
        if ok then
            print("OK")
            passed = passed + 1
        else
            print("FAIL\n   "..err)
            failed = failed + 1
        end
    end
    print(("ALL DONE. Passed=%d, Failed=%d"):format(passed, failed))
    print("")
end

-------------------------------------
-- 4) TESTS: Config
-------------------------------------
it("Config initializes defaults properly", function()
    _G.CommandSageDB = {}
    CommandSage_Config:InitializeDefaults()
    assert(_G.CommandSageDB.config.preferences, "Expected preferences to exist")
    assert(_G.CommandSageDB.config.preferences.suggestionMode == "fuzzy",
            "Default suggestionMode should be 'fuzzy'")
end)

it("Config sets and gets preferences", function()
    _G.CommandSageDB = {}
    CommandSage_Config:InitializeDefaults()
    CommandSage_Config.Set("preferences", "uiTheme", "light")
    local v = CommandSage_Config.Get("preferences", "uiTheme")
    assert(v == "light","Expected uiTheme=light but got "..tostring(v))
end)

it("Config resets to default", function()
    _G.CommandSageDB = {}
    CommandSage_Config:InitializeDefaults()
    CommandSage_Config.Set("preferences","uiTheme","light")
    assert(CommandSage_Config.Get("preferences","uiTheme")=="light")
    CommandSage_Config:ResetPreferences()
    assert(CommandSage_Config.Get("preferences","uiTheme")=="dark",
            "Expected dark after reset")
end)

-------------------------------------
-- 5) TESTS: Trie
-------------------------------------
it("Trie inserts and finds prefixes", function()
    CommandSage_Trie:Clear()
    CommandSage_Trie:InsertCommand("/dance", {desc="dance"})
    CommandSage_Trie:InsertCommand("/da", {desc="da"})
    local results = CommandSage_Trie:FindPrefix("/da")
    assert(#results >= 2, "Should find both /dance and /da")
end)

it("Trie removes commands", function()
    CommandSage_Trie:Clear()
    CommandSage_Trie:InsertCommand("/macro", {desc="macro"})
    local found = CommandSage_Trie:FindPrefix("/macro")
    assert(#found == 1, "Should find /macro")

    CommandSage_Trie:RemoveCommand("/macro")
    local found2 = CommandSage_Trie:FindPrefix("/macro")
    assert(#found2 == 0, "Should not find after removal")
end)

-------------------------------------
-- 6) TESTS: FuzzyMatch
-------------------------------------
it("FuzzyMatch suggests close strings", function()
    CommandSage_Trie:Clear()
    CommandSage_Trie:InsertCommand("/dance", {})
    local possible = CommandSage_Trie:AllCommands()
    local results = CommandSage_FuzzyMatch:GetSuggestions("/danc", possible)
    local foundDance = false
    for _,r in ipairs(results) do
        if r.slash == "/dance" then
            foundDance = true
        end
    end
    assert(foundDance, "Expected to fuzzy-match /dance from /danc")
end)

-------------------------------------
-- 7) TESTS: Discovery
-------------------------------------
it("Discovery scans built-ins + macros + fallback", function()
    _G.CommandSageDB = {}
    CommandSage_Config:InitializeDefaults()
    CommandSage_Discovery:ScanAllCommands()
    local discovered = CommandSage_Discovery:GetDiscoveredCommands()
    assert(discovered["/dance"], "Expected /dance from fallback or global env")
    assert(discovered["/testmacro"] or discovered["/world"],
            "Expected macros from GetMacroInfo in discovered list")
end)

-------------------------------------
-- 8) TESTS: AutoComplete
-------------------------------------
it("AutoComplete merges history if partial not in trie", function()
    _G.CommandSageDB = {}
    CommandSage_Config:InitializeDefaults()
    CommandSage_Trie:Clear()
    -- Add custom command only in history:
    CommandSage_HistoryPlayback:GetHistory()
    CommandSage_HistoryPlayback:AddToHistory("/coolcmd")

    local suggestions = CommandSage_AutoComplete:GenerateSuggestions("cool")
    local found = false
    for _,s in ipairs(suggestions) do
        if s.slash == "/coolcmd" then
            found = true
        end
    end
    assert(found, "Expected /coolcmd from history fallback")
end)

-------------------------------------
-- 9) TESTS: Fallback
-------------------------------------
it("Fallback toggles on/off", function()
    CommandSage_Fallback:DisableFallback()
    assert(CommandSage_Fallback:IsFallbackActive()==false,"Should be off initially")

    CommandSage_Fallback:EnableFallback()
    assert(CommandSage_Fallback:IsFallbackActive()==true,"Should be on now")

    CommandSage_Fallback:ToggleFallback()
    assert(CommandSage_Fallback:IsFallbackActive()==false,"Should be off after toggle")
end)

-------------------------------------
-- 10) TESTS: ParameterHelper
-------------------------------------
it("ParameterHelper suggests for /dance fancy", function()
    local results = CommandSage_ParameterHelper:GetParameterSuggestions("/dance","f")
    local foundFancy = false
    for _,r in ipairs(results) do
        if r == "fancy" then
            foundFancy = true
        end
    end
    assert(foundFancy, "Expected param suggestion 'fancy'")
end)

-------------------------------------
-- 11) TESTS: Licensing
-------------------------------------
it("Licensing default is not Pro unless monetizationEnabled", function()
    _G.CommandSageDB = {}
    CommandSage_Config:InitializeDefaults()
    assert(CommandSage_Licensing:IsProActive()==true,
            "Should be active if monetizationEnabled=false by default")
end)

it("Licensing with key recognized as pro", function()
    _G.CommandSageDB = {}
    CommandSage_Config:InitializeDefaults()
    CommandSage_Config.Set("preferences","monetizationEnabled",true)
    CommandSage_Licensing:HandleLicenseCommand("MY-PRO-KEY")
    assert(CommandSage_Licensing:IsProActive()==true, "Should be pro after valid key")
end)

-------------------------------------
-- 12) TESTS: Analytics (favorites)
-------------------------------------
it("Analytics favorites and blacklists", function()
    _G.CommandSageDB = {}
    CommandSage_Analytics:AddFavorite("/dance")
    assert(CommandSage_Analytics:IsFavorite("/dance"),
            "Expected /dance to be favorite")

    CommandSage_Analytics:Blacklist("/macro")
    assert(CommandSage_Analytics:IsBlacklisted("/macro"),
            "Expected /macro to be blacklisted")

    CommandSage_Analytics:Unblacklist("/macro")
    assert(not CommandSage_Analytics:IsBlacklisted("/macro"),
            "/macro should no longer be blacklisted")
end)

-------------------------------------
-- 13) Test Runner
-------------------------------------
runTests()
