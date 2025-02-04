-- tests\test_all.lua
-- Master test runner using Busted on Windows.

require("busted.runner")()

-- Load mocks first
dofile("tests/mocks.lua")

-- Then load test files
dofile("tests/test_Config.lua")
dofile("tests/test_Trie.lua")
dofile("tests/test_AutoComplete.lua")
dofile("tests/test_FuzzyMatch.lua")
dofile("tests/test_ParameterHelper.lua")
