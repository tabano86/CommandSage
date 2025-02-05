-- tests/test_helper.lua
-- Common setup so each test sees the same environment.

-- 1) WoW environment mock
require("tests.wow_mock")

-- 2) Let Lua find your "Core/" and "Modules/" files easily.
local rootPath = "./"  -- or wherever your CommandSage/ is relative to test_helper
package.path = package.path
        .. ";" .. rootPath .. "Core/?.lua"
        .. ";" .. rootPath .. "Modules/?.lua"
        .. ";" .. rootPath .. "?.lua"

-- 3) If you want to automatically do Busted's runner here, you can:
-- require("busted.runner")()

-- Optionally define _TEST so your modules know they are in test mode if needed.
_G._TEST = true
