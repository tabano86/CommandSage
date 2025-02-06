-- tests/loader.lua
print("loader.lua start.")

-- 1) Make sure we load the config first, so that _G.CommandSage_Config is defined.
_G.CommandSage_Config = require("Core.CommandSage_Config")

-- 2) Load your other core modules (which themselves reference CommandSage_Config).
_G.CommandSage_Core = require("Core.CommandSage_Core")
_G.CommandSage_Discovery = require("Core.CommandSage_Discovery")

-- 3) Load modules in your .toc order. We store them in _G so global references match:
_G.CommandSage_Trie = require("Modules.CommandSage_Trie")
_G.CommandSage_FuzzyMatch = require("Modules.CommandSage_FuzzyMatch")
_G.CommandSage_ParameterHelper = require("Modules.CommandSage_ParameterHelper")
_G.CommandSage_AdaptiveLearning = require("Modules.CommandSage_AdaptiveLearning")
_G.CommandSage_PersistentTrie = require("Modules.CommandSage_PersistentTrie")
_G.CommandSage_Tutorial = require("Modules.CommandSage_Tutorial")
_G.CommandSage_Performance = require("Modules.CommandSage_Performance")
_G.CommandSage_SecureCallback = require("Modules.CommandSage_SecureCallback")
_G.CommandSage_Fallback = require("Modules.CommandSage_Fallback")
_G.CommandSage_CommandOrganizer = require("Modules.CommandSage_CommandOrganizer")
_G.CommandSage_AutoType = require("Modules.CommandSage_AutoType")
_G.CommandSage_HistoryPlayback = require("Modules.CommandSage_HistoryPlayback")
_G.CommandSage_DeveloperAPI = require("Modules.CommandSage_DeveloperAPI")
_G.CommandSage_UIAccessibility = require("Modules.CommandSage_UIAccessibility")
_G.CommandSage_Analytics = require("Modules.CommandSage_Analytics")
_G.CommandSage_MultiModal = require("Modules.CommandSage_MultiModal")
_G.CommandSage_AROverlays = require("Modules.CommandSage_AROverlays")
_G.CommandSage_AutoComplete = require("Modules.CommandSage_AutoComplete")
_G.CommandSage_Terminal = require("Modules.CommandSage_Terminal")
_G.CommandSage_ShellContext = require("Modules.CommandSage_ShellContext")
_G.CommandSage_Licensing = require("Modules.CommandSage_Licensing")
_G.CommandSage_ConfigGUI = require("Modules.CommandSage_ConfigGUI")
_G.CommandSage_KeyBlocker = require("Modules.CommandSage_KeyBlocker")

print("loader.lua: finished loading in .toc order.")
