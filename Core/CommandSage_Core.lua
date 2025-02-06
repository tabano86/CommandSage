-- Core/CommandSage_Core.lua
-- In a live WoW addon the addon name is passed via ...; in our test environment we default to "CommandSage".
local addonName = "CommandSage"
-- (If running in WoW and you want to use the passed value, you might do:
--    local addonName = select(1, ...) or "CommandSage"
-- but in our test environment this avoids the “cannot use '...'” error.)

CommandSage = {}
_G["CommandSage"] = CommandSage

-- Create our main frame for event handling.
local f = CreateFrame("Frame", "CommandSageMainFrame", UIParent)
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("ADDON_UNLOADED")

-- Ensure string.trim exists.
if not string.trim then
    function string:trim()
        return self:match("^%s*(.-)%s*$")
    end
end

-- Ensure strsplit exists.
if not strsplit then
    function strsplit(delimiter, text)
        if type(text) ~= "string" then
            return {}
        end
        local list = {}
        for token in string.gmatch(text, "[^" .. delimiter .. "]+") do
            table.insert(list, token)
        end
        return unpack(list)
    end
end

--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------
local function OnEvent(self, event, ...)
    local ok, err = pcall(function()
        if event == "ADDON_LOADED" then
            local loadedAddon = ...
            if loadedAddon == addonName then
                -- Initialize configuration.
                if CommandSage_Config and CommandSage_Config.InitializeDefaults then
                    CommandSage_Config:InitializeDefaults()
                else
                    print("Error: CommandSage_Config.InitializeDefaults not available.")
                end
                -- Clear any old shell context.
                if CommandSage_ShellContext and CommandSage_ShellContext.ClearContext then
                    CommandSage_ShellContext:ClearContext()
                end
                -- Initialize terminal goodies if enabled.
                if CommandSage_Config
                        and CommandSage_Config.Get("preferences", "enableTerminalGoodies")
                        and CommandSage_Terminal and CommandSage_Terminal.Initialize then
                    CommandSage_Terminal:Initialize()
                end
                -- Load persistent trie data.
                if CommandSage_PersistentTrie and CommandSage_PersistentTrie.LoadTrie then
                    CommandSage_PersistentTrie:LoadTrie()
                end
                -- Scan for slash commands.
                if CommandSage_Discovery and CommandSage_Discovery.ScanAllCommands then
                    CommandSage_Discovery:ScanAllCommands()
                end
                -- Register slash commands.
                if CommandSage.RegisterSlashCommands then
                    CommandSage:RegisterSlashCommands()
                end
                -- Initialize configuration GUI if enabled.
                if CommandSage_Config
                        and CommandSage_Config.Get("preferences", "configGuiEnabled")
                        and CommandSage_ConfigGUI and CommandSage_ConfigGUI.InitGUI then
                    CommandSage_ConfigGUI:InitGUI()
                end
                -- Hook all chat frames.
                if CommandSage.HookAllChatFrames then
                    CommandSage:HookAllChatFrames()
                end
            end
        elseif event == "PLAYER_LOGIN" then
            if CommandSage_Config
                    and CommandSage_Config.Get("preferences", "showTutorialOnStartup")
                    and CommandSage_Tutorial and CommandSage_Tutorial.ShowTutorialPrompt then
                CommandSage_Tutorial:ShowTutorialPrompt()
            end
        elseif event == "ADDON_UNLOADED" then
            local unloadedAddon = ...
            if unloadedAddon == addonName then
                -- Do not clear the shell context so that it remains intact.
            end
        end
    end)
    if not ok then
        print("Error handling event " .. event .. ": " .. err)
    end
end

f:SetScript("OnEvent", OnEvent)

--------------------------------------------------------------------------------
-- Slash Command Registration
--------------------------------------------------------------------------------
function CommandSage:RegisterSlashCommands()
    SLASH_COMMANDSAGE1 = "/cmdsage"
    SlashCmdList["COMMANDSAGE"] = function(msg)
        local args = { strsplit(" ", msg or "") }
        local cmd = args[1] or ""
        if cmd == "tutorial" then
            if CommandSage_Tutorial and CommandSage_Tutorial.ShowTutorialPrompt then
                CommandSage_Tutorial:ShowTutorialPrompt()
            end
        elseif cmd == "scan" then
            if CommandSage_Discovery and CommandSage_Discovery.ScanAllCommands then
                CommandSage_Discovery:ScanAllCommands()
                print("CommandSage: Force re-scan done.")
            end
        elseif cmd == "fallback" then
            if CommandSage_Fallback and CommandSage_Fallback.EnableFallback then
                CommandSage_Fallback:EnableFallback()
                print("Fallback ON.")
            end
        elseif cmd == "nofallback" then
            if CommandSage_Fallback and CommandSage_Fallback.DisableFallback then
                CommandSage_Fallback:DisableFallback()
                print("Fallback OFF.")
            end
        elseif cmd == "togglefallback" then
            if CommandSage_Fallback and CommandSage_Fallback.ToggleFallback then
                CommandSage_Fallback:ToggleFallback()
            end
        elseif cmd == "debug" then
            if CommandSage_DeveloperAPI and CommandSage_DeveloperAPI.DebugDump then
                CommandSage_DeveloperAPI:DebugDump()
            end
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
            if CommandSage_ConfigGUI and CommandSage_ConfigGUI.Toggle then
                CommandSage_ConfigGUI:Toggle()
            else
                print("Config GUI not available.")
            end
        elseif cmd == "resetprefs" then
            if CommandSage_Config and CommandSage_Config.ResetPreferences then
                CommandSage_Config:ResetPreferences()
            end
        elseif cmd == "perf" then
            if CommandSage_Performance and CommandSage_Performance.ShowDashboard then
                CommandSage_Performance:ShowDashboard()
            end
        else
            print("|cff00ff00CommandSage Usage:|r")
            print(" /cmdsage tutorial")
            print(" /cmdsage scan")
            print(" /cmdsage fallback/nofallback/togglefallback")
            print(" /cmdsage debug")
            print(" /cmdsage config <key> <value>")
            print(" /cmdsage mode <fuzzy|strict>")
            print(" /cmdsage theme <dark|light|classic>")
            print(" /cmdsage scale <number>")
            print(" /cmdsage resetprefs")
            print(" /cmdsage gui")
            print(" /cmdsage perf")
        end
    end
end

--------------------------------------------------------------------------------
-- Hook Chat Frame EditBox
-- This function attaches custom key and text-change handlers to a chat edit box.
--------------------------------------------------------------------------------
function CommandSage:HookChatFrameEditBox(editBox)
    if not editBox or editBox.CommandSageHooked then
        return
    end

    local bindingManagerFrame = CreateFrame("Frame", nil)
    local function DisableAllBindings()
        local override = CommandSage_Config.Get("preferences", "overrideHotkeysWhileTyping")
        local always = CommandSage_Config.Get("preferences", "alwaysDisableHotkeysInChat")
        if not override and not always then
            return
        end
        for i = 1, GetNumBindings() do
            local command, key1, key2 = GetBinding(i)
            if key1 then
                SetOverrideBinding(bindingManagerFrame, true, key1, nil)
            end
            if key2 then
                SetOverrideBinding(bindingManagerFrame, true, key2, nil)
            end
        end
    end
    local function RestoreAllBindings()
        ClearOverrideBindings(bindingManagerFrame)
    end

    editBox:HookScript("OnEditFocusGained", function(self)
        pcall(DisableAllBindings)
        self:SetPropagateKeyboardInput(false)
        if CommandSage_KeyBlocker and CommandSage_KeyBlocker.BlockKeys then
            pcall(CommandSage_KeyBlocker.BlockKeys, CommandSage_KeyBlocker)
        end
        if CommandSage_Config.Get("preferences", "chatInputHaloEnabled") then
            self:SetBackdropColor(1, 1, 0, 0.2)
        end
    end)

    editBox:HookScript("OnEditFocusLost", function(self)
        pcall(RestoreAllBindings)
        self:SetPropagateKeyboardInput(true)
        if CommandSage_KeyBlocker and CommandSage_KeyBlocker.UnblockKeys then
            pcall(CommandSage_KeyBlocker.UnblockKeys, CommandSage_KeyBlocker)
        end
        if CommandSage_Config.Get("preferences", "chatInputHaloEnabled") then
            self:SetBackdropColor(0, 0, 0, 0)
        end
    end)

    local function CloseAutoCompleteOnChatDeactivate()
        if CommandSage_AutoComplete and CommandSage_AutoComplete.CloseSuggestions then
            pcall(CommandSage_AutoComplete.CloseSuggestions, CommandSage_AutoComplete)
        end
    end
    hooksecurefunc("ChatEdit_DeactivateChat", CloseAutoCompleteOnChatDeactivate)

    editBox:HookScript("OnKeyDown", function(self, key)
        local text = self:GetText() or ""
        local isSlash = (text:sub(1, 1) == "/")
        local isInShellContext = (CommandSage_ShellContext and CommandSage_ShellContext:IsActive()) or false
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
                if CommandSage_AutoComplete then
                    CommandSage_AutoComplete:CloseSuggestions()
                end
                return
            end
        else
            self:SetPropagateKeyboardInput(true)
        end
    end)

    local orig = editBox:GetScript("OnTextChanged")
    editBox:SetScript("OnTextChanged", function(eBox, userInput)
        if orig then
            pcall(orig, eBox, userInput)
        end
        if not userInput then
            return
        end
        if CommandSage_Fallback and CommandSage_Fallback.IsFallbackActive and CommandSage_Fallback:IsFallbackActive() then
            return
        end
        local text = eBox:GetText()
        if text == "" then
            if CommandSage_AutoComplete then
                CommandSage_AutoComplete:CloseSuggestions()
            end
            return
        end
        local firstChar = text:sub(1, 1)
        if firstChar ~= "/" and not (CommandSage_ShellContext and CommandSage_ShellContext:IsActive()) then
            if CommandSage_AutoComplete then
                CommandSage_AutoComplete:CloseSuggestions()
            end
            return
        end
        local firstWord = text:match("^(%S+)")
        local rest = text:match("^%S+%s+(.*)") or ""
        local paramHints = {}
        if CommandSage_ParameterHelper and CommandSage_ParameterHelper.GetParameterSuggestions then
            paramHints = CommandSage_ParameterHelper:GetParameterSuggestions(firstWord, rest) or {}
        end
        if #paramHints > 0 then
            local paramSugg = {}
            for _, ph in ipairs(paramHints) do
                table.insert(paramSugg, {
                    slash = firstWord .. " " .. ph,
                    data = { description = "[Arg completion]" },
                    rank = 0,
                    isParamSuggestion = true
                })
            end
            if CommandSage_AutoComplete and CommandSage_AutoComplete.ShowSuggestions then
                CommandSage_AutoComplete:ShowSuggestions(paramSugg)
            end
            return
        end
        local final = {}
        if CommandSage_AutoComplete and CommandSage_AutoComplete.GenerateSuggestions then
            final = CommandSage_AutoComplete:GenerateSuggestions(text) or {}
        end
        if CommandSage_AutoComplete and CommandSage_AutoComplete.ShowSuggestions then
            CommandSage_AutoComplete:ShowSuggestions(final)
        end
    end)
    editBox.CommandSageHooked = true
end

--------------------------------------------------------------------------------
-- Hook all chat frames
--------------------------------------------------------------------------------
function CommandSage:HookAllChatFrames()
    for i = 1, NUM_CHAT_WINDOWS do
        local cf = _G["ChatFrame" .. i]
        local editBox = cf and cf.editBox
        if editBox then
            self:HookChatFrameEditBox(editBox)
        end
    end
end

-- Set the main frame’s event handler.
f:SetScript("OnEvent", OnEvent)
CommandSage.frame = f
