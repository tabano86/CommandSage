--==========================
-- tests/loader.lua
--==========================
-- This file forces the same load order as your .toc. The key is to require
-- all modules in dependency order so that each one sees the expected globals.

-- 1) Load the WoW API mock & test helper
-- (We'll expect test_helper.lua to have loaded wow_mock, or vice versa.)
-- If you'd rather do it here, you can do:
-- require("tests.wow_mock")

-- 2) Reflect the .toc order for the addon:

-- Core
require("Core.CommandSage_Config")
require("Core.CommandSage_Core")
require("Core.CommandSage_Discovery")

-- Modules
require("Modules.CommandSage_Trie")
require("Modules.CommandSage_FuzzyMatch")
require("Modules.CommandSage_ParameterHelper")
require("Modules.CommandSage_AdaptiveLearning")
require("Modules.CommandSage_PersistentTrie")
require("Modules.CommandSage_Tutorial")
require("Modules.CommandSage_Performance")
require("Modules.CommandSage_SecureCallback")
require("Modules.CommandSage_Fallback")
require("Modules.CommandSage_CommandOrganizer")
require("Modules.CommandSage_AutoType")
require("Modules.CommandSage_HistoryPlayback")
require("Modules.CommandSage_DeveloperAPI")
require("Modules.CommandSage_UIAccessibility")
require("Modules.CommandSage_Analytics")
require("Modules.CommandSage_MultiModal")
require("Modules.CommandSage_AROverlays")
require("Modules.CommandSage_AutoComplete")
require("Modules.CommandSage_Terminal")
require("Modules.CommandSage_ShellContext")
require("Modules.CommandSage_Licensing")
require("Modules.CommandSage_ConfigGUI")
require("Modules.CommandSage_KeyBlocker")

-- Now all of the CommandSage_… modules are effectively loaded and placed
-- in the global environment. Your tests can reference them.


--------------------------------------------------------------------------------
print("loader.lua: finished loading modules in .toc order.")
