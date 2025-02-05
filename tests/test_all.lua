-- tests\test_all.lua
-- Master test runner using Busted.

require("busted.runner")()

-- Load mocks
require("tests.mocks")

-- Core tests (30 total in separate files):
require("tests.test_ConfigCore")
require("tests.test_CoreMain")
require("tests.test_DiscoveryCore")

-- Module tests (10 each):
require("tests.test_AdaptiveLearning")
require("tests.test_Analytics")
require("tests.test_AROverlays")
require("tests.test_AutoComplete2")
require("tests.test_AutoType")
require("tests.test_CommandOrganizer.lua")
require("tests.test_ConfigGUI")
require("tests.test_DeveloperAPI")
require("tests.test_Fallback")
require("tests.test_FuzzyMatch2")
require("tests.test_HistoryPlayback")
require("tests.test_KeyBlocker")
require("tests.test_Licensing")
require("tests.test_MultiModal")
require("tests.test_ParameterHelper2")
require("tests.test_Performance")
require("tests.test_PersistentTrie")
require("tests.test_SecureCallback")
require("tests.test_ShellContext")
require("tests.test_Terminal")
require("tests.test_Tutorial")
require("tests.test_UIAccessibility")
