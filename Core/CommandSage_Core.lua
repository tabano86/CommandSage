-- =============================================================================
-- CommandSage_Core.lua
-- =============================================================================

local addonName, _ = ...

CommandSage = {}
_G["CommandSage"] = CommandSage

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("ADDON_UNLOADED") -- to fix bug where shell might stay stuck

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

            -- Hook to *all* chat frames
            CommandSage:HookAllChatFrames()
        end

    elseif event == "PLAYER_LOGIN" then
        if CommandSage_Config.Get("preferences", "showTutorialOnStartup") then
            CommandSage_Tutorial:ShowTutorialPrompt()
        end

    elseif event == "ADDON_UNLOADED" then
        local unloadedAddon = ...
        if unloadedAddon == addonName then
            -- Clear shell context if stuck
            CommandSage_ShellContext:HandleCd("clear")
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
        elseif cmd == "togglefallback" then
            CommandSage_Fallback:ToggleFallback()
        elseif cmd == "debug" then
            CommandSage_DeveloperAPI:DebugDump()
        elseif cmd == "config" then
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
            local modeVal = args[2]
            if modeVal == "fuzzy" or modeVal == "strict" then
                CommandSage_Config.Set("preferences", "suggestionMode", modeVal)
                print("Suggestion mode =", modeVal)
            else
                print("Usage: /cmdsage mode <fuzzy|strict>")
            end
        elseif cmd == "theme" then
            local themeVal = args[2]
            if themeVal then
                CommandSage_Config.Set("preferences", "uiTheme", themeVal)
                print("UI theme set to", themeVal)
            else
                print("Usage: /cmdsage theme <dark|light|classic>")
            end
        elseif cmd == "scale" then
            local scaleVal = args[2] and tonumber(args[2])
            if scaleVal then
                CommandSage_Config.Set("preferences", "uiScale", scaleVal)
                print("UI scale set to", scaleVal)
            else
                print("Usage: /cmdsage scale <number>")
            end
        elseif cmd == "gui" then
            if CommandSage_ConfigGUI then
                CommandSage_ConfigGUI:Toggle()
            else
                print("Config GUI not available.")
            end
        elseif cmd == "resetprefs" then
            CommandSage_Config:ResetPreferences()
        elseif cmd == "perf" then
            CommandSage_Performance:ShowDashboard()
        else
            print("|cff00ff00CommandSage Usage:|r")
            print(" /cmdsage tutorial - Show tutorial")
            print(" /cmdsage scan - Re-scan commands")
            print(" /cmdsage fallback/nofallback/togglefallback")
            print(" /cmdsage debug - Show debug info")
            print(" /cmdsage config <key> <value> - Set config")
            print(" /cmdsage mode <fuzzy|strict> - Switch suggestion mode")
            print(" /cmdsage theme <dark|light|classic> - Set UI theme")
            print(" /cmdsage scale <1.0> - Set autocomplete UI scale")
            print(" /cmdsage resetprefs - Reset all preferences to default")
            print(" /cmdsage gui - Open/close the config panel")
            print(" /cmdsage perf - Show performance dashboard")
        end
    end
end

function CommandSage:HookChatFrameEditBox(editBox)
    if not editBox or editBox.CommandSageHooked then return end

    local bindingManagerFrame = CreateFrame("Frame", nil)

    local function DisableAllBindings()
        local override = CommandSage_Config.Get("preferences", "overrideHotkeysWhileTyping")
        local always   = CommandSage_Config.Get("preferences", "alwaysDisableHotkeysInChat")
        if not override and not always then
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

    editBox:HookScript("OnEditFocusGained", function(self)
        DisableAllBindings()
        self:SetPropagateKeyboardInput(false)
        CommandSage_KeyBlocker:BlockKeys()

        -- Chat halo if enabled
        if CommandSage_Config.Get("preferences", "chatInputHaloEnabled") then
            self:SetBackdropColor(1, 1, 0, 0.2) -- simple halo
        end
    end)

    editBox:HookScript("OnEditFocusLost", function(self)
        RestoreAllBindings()
        self:SetPropagateKeyboardInput(true)
        CommandSage_KeyBlocker:UnblockKeys()

        if CommandSage_Config.Get("preferences", "chatInputHaloEnabled") then
            self:SetBackdropColor(0,0,0,0)
        end
    end)

    local function CloseAutoCompleteOnChatDeactivate()
        CommandSage_AutoComplete:CloseSuggestions()
    end
    hooksecurefunc("ChatEdit_DeactivateChat", CloseAutoCompleteOnChatDeactivate)

    editBox:HookScript("OnKeyDown", function(self, key)
        local text = self:GetText() or ""
        local isSlash = (text:sub(1,1) == "/")
        local isInShellContext = CommandSage_ShellContext:IsActive()

        if not CommandSage_Config.Get("preferences", "advancedKeybinds") then
            self:SetPropagateKeyboardInput(true)
            return
        end

        if isSlash or isInShellContext then
            self:SetPropagateKeyboardInput(false)

            if key == "UP" then
                if IsShiftKeyDown() then
                    CommandSage_AutoComplete:MoveSelection(-5)
                else
                    CommandSage_AutoComplete:MoveSelection(-1)
                end
                return
            elseif key == "DOWN" then
                if IsShiftKeyDown() then
                    CommandSage_AutoComplete:MoveSelection(5)
                else
                    CommandSage_AutoComplete:MoveSelection(1)
                end
                return
            elseif key == "TAB" then
                if IsShiftKeyDown() then
                    CommandSage_AutoComplete:MoveSelection(-1)
                else
                    CommandSage_AutoComplete:AcceptOrAdvance()
                end
                return
            elseif key == "C" and IsControlKeyDown() then
                self:SetText("")
                CommandSage_AutoComplete:CloseSuggestions()
                return
            end
        else
            self:SetPropagateKeyboardInput(true)
        end
    end)

    local orig = editBox:GetScript("OnTextChanged")
    editBox:SetScript("OnTextChanged", function(eBox, userInput)
        if orig then
            orig(eBox, userInput)
        end
        if not userInput then
            return
        end
        if CommandSage_Fallback:IsFallbackActive() then
            return
        end

        local text = eBox:GetText()
        if text == "" then
            CommandSage_AutoComplete:CloseSuggestions()
            return
        end

        local firstChar = text:sub(1,1)
        if firstChar ~= "/" and not CommandSage_ShellContext:IsActive() then
            CommandSage_AutoComplete:CloseSuggestions()
            return
        end

        local firstWord = text:match("^(%S+)")
        local rest = text:match("^%S+%s+(.*)") or ""
        local paramHints = CommandSage_ParameterHelper:GetParameterSuggestions(firstWord, rest)
        if #paramHints > 0 then
            local paramSugg = {}
            for _, ph in ipairs(paramHints) do
                table.insert(paramSugg, {
                    slash = firstWord .. " " .. ph,
                    data  = { description = "[Arg completion]" },
                    rank  = 0,
                    isParamSuggestion = true
                })
            end
            CommandSage_AutoComplete:ShowSuggestions(paramSugg)
            return
        end

        local final = CommandSage_AutoComplete:GenerateSuggestions(text)
        CommandSage_AutoComplete:ShowSuggestions(final)
    end)

    editBox.CommandSageHooked = true
end

function CommandSage:HookAllChatFrames()
    for i = 1, NUM_CHAT_WINDOWS do
        local cf = _G["ChatFrame"..i]
        local editBox = cf and cf.editBox
        if editBox then
            self:HookChatFrameEditBox(editBox)
        end
    end
end

f:SetScript("OnEvent", OnEvent)
