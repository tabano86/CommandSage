-- tests/test_helper.lua
-- Loads common mocks and sets up package.path so that require can find Core/ and Modules/
require("tests.mocks")

package.path = package.path .. ";./Core/?.lua;./Modules/?.lua;./tests/?.lua;./?.lua;"

-- Ensure C_Timer is defined
if not C_Timer then
    C_Timer = { After = function(sec, func)
        func()
    end }
end

if not GetRealZoneText then
    GetRealZoneText = function() return "TestZone" end
end

if not GetSubZoneText then
    GetSubZoneText = function() return "TestSubZone" end
end

if not GetTime then
    GetTime = function() return os.time() end
end

if not date then
    date = function(fmt) return "12:34:56" end
end

if not UnitName then
    UnitName = function(unit) return (unit == "player") and "TestPlayer" or "Unknown" end
end

-- Also ensure that NUM_CHAT_WINDOWS and ChatFrame mocks exist:
if not NUM_CHAT_WINDOWS then NUM_CHAT_WINDOWS = 1 end
if not _G["ChatFrame1"] then
    _G["ChatFrame1"] = {
        Clear = function() end,
        IsVisible = function() return true end,
    }
end


_G._TEST = true
