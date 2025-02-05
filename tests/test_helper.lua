require("tests.wow_mock")
local rootPath="./"
package.path=package.path
        .. ";"..rootPath.."Core/?.lua"
        .. ";"..rootPath.."Modules/?.lua"
        .. ";"..rootPath.."?.lua"
_G._TEST=true
