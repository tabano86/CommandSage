if _G.__COMMANDSAGE_TEST_ENV_LOADED then
    return
end
_G.__COMMANDSAGE_TEST_ENV_LOADED = true

print("test_helper.lua loaded...")

require("tests.wow_mock")
package.path = package.path
        .. ";./Core/?.lua"
        .. ";./Modules/?.lua"
        .. ";./tests/?.lua"
        .. ";./?.lua;"

if not string.trim then
    function string:trim()
        return self:match("^%s*(.-)%s*$")
    end
end

require("tests.loader")

print("test_helper done init (only once).")
