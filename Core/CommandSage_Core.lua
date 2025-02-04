-- =============================================================================
-- CommandSage_Core.lua
-- Entry point for the CommandSage addon
-- =============================================================================

local addonName, _ = ...

CommandSage = {}
_G["CommandSage"] = CommandSage

local coreFrame = CreateFrame("Frame")
coreFrame:RegisterEvent("ADDON_LOADED")
coreFrame:RegisterEvent("PLAYER_LOGIN")

local function OnEvent(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon == addonName then
            CommandSage_Config:InitializeDefaults()

            -- Load saved Trie, then do a re-scan
            CommandSage_PersistentTrie:LoadTrie()
            CommandSage_Discovery:ScanAllCommands()

            CommandSage:RegisterSlashCommands()
        end
    elseif event == "PLAYER_LOGIN" then
        if CommandSage_Config.Get("preferences", "showTutorialOnStartup") then
            CommandSage_Tutorial:ShowTutorialPrompt()
        end
    end
end

function CommandSage:RegisterSlashCommands()
    SLASH_COMMANDSAGE1 = "/cmdsage"
    SlashCmdList["COMMANDSAGE"] = function(msg)
        local args = { strsplit(" ", msg or "") }
        local cmd = args[1] or ""
        if cmd == "tutorial" then
            CommandSage_Tutorial:ShowTutorialPrompt()
        elseif cmd == "scan" then
            CommandSage_Discovery:ScanAllCommands()
            print("CommandSage: Force re-scan completed.")
        elseif cmd == "fallback" then
            CommandSage_Fallback:EnableFallback()
            print("CommandSage: Fallback mode activated.")
        elseif cmd == "nofallback" then
            CommandSage_Fallback:DisableFallback()
            print("CommandSage: Fallback mode disabled.")
        elseif cmd == "debug" then
            CommandSage_DeveloperAPI:DebugDump()
        else
            print("|cff00ff00CommandSage Usage:|r")
            print("/cmdsage tutorial - Show tutorial")
            print("/cmdsage scan - Re-scan all slash commands")
            print("/cmdsage fallback - Enable fallback mode")
            print("/cmdsage nofallback - Disable fallback mode")
            print("/cmdsage debug - Dump debug info")
        end
    end
end

coreFrame:SetScript("OnEvent", OnEvent)
