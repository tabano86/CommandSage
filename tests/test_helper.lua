-- tests/test_helper.lua

-- 1. Update package search paths for both mobdebug and LuaSocket.
package.path = package.path
        .. ";/home/dirtbikr/.luarocks/share/lua/5.3/?.lua"
        .. ";/home/dirtbikr/.luarocks/share/lua/5.3/?/init.lua"
        .. ";./Libs/MobDebug-master/src/?.lua"
        .. ";./Libs/MobDebug-master/src/?/init.lua"
        .. ";./Core/?.lua;./Modules/?.lua;./tests/?.lua;./?.lua"

package.cpath = package.cpath
        .. ";/home/dirtbikr/.luarocks/lib/lua/5.3/?.so"

-- 2. (Optional) Ensure string.trim exists.
if not string.trim then
    function string:trim()
        return self:match("^%s*(.-)%s*$")
    end
end

-- 3. Load WoW API stubs.
require("tests.wow_mock")

-- 4. Prevent duplicate test environment setup.
if _G.__COMMANDSAGE_TEST_ENV_LOADED then return end
_G.__COMMANDSAGE_TEST_ENV_LOADED = true

print("test_helper.lua loaded...")

-- 5. Load modules in .toc order.
require("tests.loader")
print("test_helper.lua: environment ready.")

-- 6. Now load mobdebug (it will find LuaSocket via the updated paths) and start it.
local mobdebug = require("mobdebug")
mobdebug.start()  -- This will wait until a debugger attaches.
