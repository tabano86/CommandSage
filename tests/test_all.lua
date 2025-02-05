-- tests\test_all.lua
-- Master test runner using Busted.

require("busted.runner")()

-- Load mocks
dofile("tests/mocks.lua")

-- Core tests (30 total in separate files):
dofile("tests/test_ConfigCore.lua")
dofile("tests/test_CoreMain.lua")
dofile("tests/test_DiscoveryCore.lua")

-- Module tests (10 each):
dofile("tests/test_AdaptiveLearning.lua")
dofile("tests/test_Analytics.lua")
dofile("tests/test_AROverlays.lua")
dofile("tests/test_AutoComplete2.lua")
dofile("tests/test_AutoType.lua")
dofile("tests/test_CommandOrganizer.lua.lua")
dofile("tests/test_ConfigGUI.lua")
dofile("tests/test_DeveloperAPI.lua")
dofile("tests/test_Fallback.lua")
dofile("tests/test_FuzzyMatch2.lua")
dofile("tests/test_HistoryPlayback.lua")
dofile("tests/test_KeyBlocker.lua")
dofile("tests/test_Licensing.lua")
dofile("tests/test_MultiModal.lua")
dofile("tests/test_ParameterHelper2.lua")
dofile("tests/test_Performance.lua")
dofile("tests/test_PersistentTrie.lua")
dofile("tests/test_SecureCallback.lua")
dofile("tests/test_ShellContext.lua")
dofile("tests/test_Terminal.lua")
dofile("tests/test_Tutorial.lua")
dofile("tests/test_UIAccessibility.lua")
