-- tests/test_helper.lua
-- Master test setup that only runs once thanks to our guard variable.

if _G.__COMMANDSAGE_TEST_ENV_LOADED then
    -- Already loaded the environment once, so skip.
    return
end
_G.__COMMANDSAGE_TEST_ENV_LOADED = true

print("test_helper.lua loaded...")

-- 1) Load our WoW mock environment (only once)
require("tests.wow_mock")

-- 2) Adjust package.path so we can require modules in Core/ and Modules/
package.path = package.path
        .. ";./Core/?.lua"
        .. ";./Modules/?.lua"
        .. ";./tests/?.lua"
        .. ";./?.lua;"

-- 3) Provide a global string.trim if not present
if not string.trim then
    function string:trim()
        return self:match("^%s*(.-)%s*$")
    end
end

-- 4) Force-load in .toc order to ensure our modules exist
require("tests.loader")

print("test_helper done init (only once).")
