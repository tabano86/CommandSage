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

_G._TEST = true
