-- =============================================================================
-- CommandSage_Core.lua
-- Primary entry point that sets up slash commands, loads config, etc.
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

            -- Initialize Terminal goodies if enabled
            if CommandSage_Config.Get("preferences", "enableTerminalGoodies") then
                CommandSage_Terminal:Initialize()
            end

            -- Load persistent data
            CommandSage_PersistentTrie:LoadTrie()
            CommandSage_Discovery:ScanAllCommands()
            CommandSage:RegisterSlashCommands()

            -- Initialize config GUI if allowed
            if CommandSage_Config.Get("preferences", "configGuiEnabled") then
                CommandSage_ConfigGUI:InitGUI()
            end
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
            -- e.g. /cmdsage config fuzzyMatchTolerance 3
            local key = args[2]
            local val = args[3]
            if key and val then
                if tonumber(val) then
                    val = tonumber(val)
                elseif val == "true" then
                    val = true
                elseif val == "false" then
                    val = false
                end
                CommandSage_Config.Set("preferences", key, val)
                print("Set config", key, "=", val)
            else
                print("Usage: /cmdsage config <key> <value>")
            end

        elseif cmd == "mode" then
            -- e.g. /cmdsage mode strict|fuzzy
            local modeVal = args[2]
            if modeVal == "fuzzy" or modeVal == "strict" then
                CommandSage_Config.Set("preferences", "suggestionMode", modeVal)
                print("Suggestion mode =", modeVal)
            else
                print("Usage: /cmdsage mode <fuzzy|strict>")
            end

        elseif cmd == "theme" then
            -- e.g. /cmdsage theme dark|light|classic
            local themeVal = args[2]
            if themeVal then
                CommandSage_Config.Set("preferences", "uiTheme", themeVal)
                print("UI theme set to", themeVal)
            else
                print("Usage: /cmdsage theme <dark|light|classic>")
            end

        elseif cmd == "scale" then
            -- e.g. /cmdsage scale 1.2
            local scaleVal = args[2] and tonumber(args[2])
            if scaleVal then
                CommandSage_Config.Set("preferences", "uiScale", scaleVal)
                print("UI scale set to", scaleVal)
            else
                print("Usage: /cmdsage scale <number>")
            end

        elseif cmd == "gui" then
            -- Toggle or show config GUI
            if CommandSage_ConfigGUI then
                CommandSage_ConfigGUI:Toggle()
            else
                print("Config GUI not available.")
            end

        else
            print("|cff00ff00CommandSage Usage:|r")
            print(" /cmdsage tutorial - Show tutorial")
            print(" /cmdsage scan - Re-scan commands")
            print(" /cmdsage fallback - On, nofallback - Off")
            print(" /cmdsage debug - Show debug info")
            print(" /cmdsage config <key> <val> - Set config")
            print(" /cmdsage mode <fuzzy|strict> - Switch suggestion mode")
            print(" /cmdsage theme <dark|light|classic> - Set UI theme")
            print(" /cmdsage scale <1.0> - Set autocomplete UI scale")
            print(" /cmdsage gui - Open/close the config panel")
        end
    end
end

-- Keybinding override to avoid conflicts while typing
local bindingManagerFrame = CreateFrame("Frame", "CommandSageBindingManagerFrame")

local function DisableAllBindings()
    if not CommandSage_Config.Get("preferences", "overrideHotkeysWhileTyping") then
        return
    end
    for i = 1, GetNumBindings() do
        local command, key1, key2 = GetBinding(i)
        if key1 then SetOverrideBinding(bindingManagerFrame, true, key1, nil) end
        if key2 then SetOverrideBinding(bindingManagerFrame, true, key2, nil) end
    end
end

local function RestoreAllBindings()
    ClearOverrideBindings(bindingManagerFrame)
end

-- Hook chat edit box events
local chatBox = ChatFrame1EditBox
chatBox:HookScript("OnEditFocusGained", function(self)
    DisableAllBindings()
end)

chatBox:HookScript("OnEditFocusLost", function(self)
    RestoreAllBindings()
end)

f:SetScript("OnEvent", OnEvent)
