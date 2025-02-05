-- tests/test_helper.lua
-- Common helper that adjusts package.path and ensures mocks are loaded first.

-- Load WoW API mocks (pick whichever you want, or both).
require("tests.mocks")
-- require("tests.wow_mock")  -- optionally comment out if "mocks.lua" suffices

-- Adjust package.path to include your Core/ and Modules/ directories.
-- So that require("Core.CommandSage_Config") or require("Modules.CommandSage_AutoComplete") will work.
package.path = package.path .. ";./Core/?.lua;./Modules/?.lua;./?.lua;"

-- Define any missing globals that your modules reference.
if not C_Timer then
    C_Timer = { After = function(sec, func) end }
end

-- Mark test mode if needed
_G._TEST = true
