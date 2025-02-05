-- tests/test_helper.lua
-- Loads common mocks and sets up your package path so that "require" can find Core/ and Modules/.

require("tests.mocks")

-- Extend the package path to include Core/ and Modules/
package.path = package.path .. ";./Core/?.lua;./Modules/?.lua;./?.lua;"

-- Define any extra global mocks if needed, for example:
if not C_Timer then
    C_Timer = { After = function(sec, func) end }
end

-- Mark that we are in test mode
_G._TEST = true
