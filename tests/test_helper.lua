-- tests/test_helper.lua
-- This file is loaded first to set up the test environment.
if _G.__COMMANDSAGE_TEST_ENV_LOADED then
    return
end
_G.__COMMANDSAGE_TEST_ENV_LOADED = true

print("test_helper.lua loaded...")

-- Load our extensive WoW API stubs.
require("tests.wow_mock")

-- Extend package.path so that modules in Core/ and Modules/ are found.
package.path = package.path
        .. ";./Core/?.lua"
        .. ";./Modules/?.lua"
        .. ";./tests/?.lua"
        .. ";./?.lua;"

-- Ensure string.trim is available.
if not string.trim then
    function string:trim()
        return self:match("^%s*(.-)%s*$")
    end
end

-- Load our loader to require all modules (simulating .toc order).
require("tests.loader")

print("test_helper.lua: environment ready.")
