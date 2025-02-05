-- tests/test_helper.lua

-- Load WoW API mocks
require("tests.wow_mock")

-- Adjust package.path to include Core and Modules directories
package.path = package.path .. ";./Core/?.lua;./Modules/?.lua;./?.lua"

-- Define any missing globals that your modules reference
if not C_Timer then
    C_Timer = { After = function(sec, func) end }
end

-- Mark test mode if needed
_G._TEST = true
