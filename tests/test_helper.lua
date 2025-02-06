--==========================
-- tests/test_helper.lua
--==========================
-- Master test helper that:
--   1) loads wow_mock
--   2) sets up package.path
--   3) ensures string.trim
--   4) calls loader.lua to mimic .toc order
--   5) does any additional test stubs or runner configs

print("test_helper.lua loaded...")

-- 1) Provide the wow_mock:
require("tests.wow_mock")

-- 2) Adjust package.path for your 'Core'/'Modules' subdirs, if needed:
package.path = package.path
        .. ";./Core/?.lua"
        .. ";./Modules/?.lua"
        .. ";./tests/?.lua"
        .. ";./?.lua;"

-- 3) Add a global trim polyfill if not present:
if not string.trim then
    function string:trim()
        return self:match("^%s*(.-)%s*$")
    end
end

-- 4) Force the .toc load order:
require("tests.loader")

-- 5) (Optional) do any busted runner config here
-- e.g. local busted = require("busted.runner")()

print("test_helper.lua: done with everything.")
