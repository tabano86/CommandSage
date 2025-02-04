-- =============================================================================
-- CommandSage_Core.lua
-- Entry point, sets up slash commands, loads config, etc.
-- =============================================================================

local addonName, _ = ...

CommandSage = {}
_G["CommandSage"] = CommandSage

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")

local function OnEvent(self, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon == addonName then
            CommandSage_Config:InitializeDefaults()
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
            print("CommandSage: Force re-scan done.")
        elseif cmd == "fallback" then
            CommandSage_Fallback:EnableFallback()
            print("Fallback ON.")
        elseif cmd == "nofallback" then
            CommandSage_Fallback:DisableFallback()
            print("Fallback OFF.")
        elseif cmd == "debug" then
            CommandSage_DeveloperAPI:DebugDump()
        elseif cmd == "config" then
            -- e.g. /cmdsage config fuzzy 3
            local key = args[2]
            local val = args[3]
            if key and val then
                if tonumber(val) then
                    val = tonumber(val)
                end
                CommandSage_Config.Set("preferences", key, val)
                print("Set config", key, "=", val)
            else
                print("Usage: /cmdsage config <key> <value>")
            end
        elseif cmd == "alias" then
            -- e.g. /cmdsage alias /greet /say Hello all
            if not CommandSage_Config.Get("preferences", "userAliasesEnabled") then
                print("User aliases disabled in config.")
                return
            end
            local aliasKey = args[2]
            local realCmd = table.concat(args, " ", 3)
            if aliasKey and realCmd then
                if not CommandSageDB.aliases then
                    CommandSageDB.aliases = {}
                end
                CommandSageDB.aliases[aliasKey:lower()] = realCmd
                print("Alias set:", aliasKey, "->", realCmd)
            else
                print("Usage: /cmdsage alias <alias> <real command>")
            end
        elseif cmd == "addfallback" then
            -- e.g. /cmdsage addfallback /mycmd
            if not CommandSage_Config.Get("preferences", "userCustomFallbackEnabled") then
                print("User custom fallback disabled in config.")
                return
            end
            local fallbackCmd = args[2]
            if fallbackCmd then
            elseif cmd == "mode" then
                -- e.g. /cmdsage mode strict|fuzzy
                local modeVal = args[2]
                if modeVal == "fuzzy" or modeVal == "strict" then
                    CommandSage_Config.Set("preferences", "suggestionMode", modeVal)
                    print("Suggestion mode =", modeVal)
                else
                    print("Usage: /cmdsage mode <fuzzy|strict>")
                end
            else
                print("|cff00ff00CommandSage Usage:|r")
                print(" /cmdsage tutorial - Show tutorial")
                print(" /cmdsage scan - Re-scan commands")
                print(" /cmdsage fallback - On, nofallback - Off")
                print(" /cmdsage debug - Show debug info")
                print(" /cmdsage config <key> <val> - Set a config param")
                print(" /cmdsage mode <fuzzy|strict> - Switch suggestion mode")
            end
        end
    end
end
f:SetScript("OnEvent", OnEvent)
