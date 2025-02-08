-- File: Core/CommandSage_Core.lua
local ADDON_NAME = "CommandSage"
CommandSage = {}
_G["CommandSage"] = CommandSage

-- Create main frame for event handling.
local mainFrame = CreateFrame("Frame", "CommandSageMainFrame", UIParent)
mainFrame:RegisterEvent("ADDON_LOADED")
mainFrame:RegisterEvent("PLAYER_LOGIN")
-- Removed registration of "ADDON_UNLOADED" as it is not a valid event in WoW Classic.
-- mainFrame:RegisterEvent("ADDON_UNLOADED")

--------------------------------------------------------------------------------
-- Debug & Utility Functions
--------------------------------------------------------------------------------
CommandSage.debugMode = false
local function debugPrint(msg)
    if CommandSage.debugMode then
        print("|cff999999[CommandSage-Debug]|r", tostring(msg))
    end
end

local function safePrint(msg)
    print("[CommandSage]: " .. tostring(msg))
end

local function safeCall(mod, methodName, ...)
    if not mod or type(mod[methodName]) ~= "function" then
        debugPrint("Method " .. tostring(methodName) .. " not available on module.")
        return
    end
    local ok, err = pcall(mod[methodName], mod, ...)
    if not ok then
        safePrint("Error calling " .. methodName .. ": " .. tostring(err))
    end
end

--------------------------------------------------------------------------------
-- Polyfills
--------------------------------------------------------------------------------
if not string.trim then
    function string:trim()
        return self:match("^%s*(.-)%s*$")
    end
end

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
-- Track configuration initialization for testing.
--------------------------------------------------------------------------------
CommandSage.coreConfigInitialized = false

--------------------------------------------------------------------------------
-- Main Event Handler
--------------------------------------------------------------------------------
local function OnEvent(self, event, param)
    local ok, err = pcall(function()
        if event == "ADDON_LOADED" then
            local loadedAddon = param
            if loadedAddon and loadedAddon:lower() == ADDON_NAME:lower() then
                if CommandSage_Config and CommandSage_Config.InitializeDefaults then
                    CommandSage_Config:InitializeDefaults()
                    CommandSage.coreConfigInitialized = true
                else
                    safePrint("Error: CommandSage_Config.InitializeDefaults not available.")
                end

                if CommandSage_ShellContext and CommandSage_ShellContext.ClearContext then
                    safeCall(CommandSage_ShellContext, "ClearContext")
                end

                if CommandSage_Config and CommandSage_Config.Get("preferences", "enableTerminalGoodies") then
                    safeCall(CommandSage_Terminal, "Initialize")
                end

                safeCall(CommandSage_PersistentTrie, "LoadTrie")
                safeCall(CommandSage_Discovery, "ScanAllCommands")

                if CommandSage.RegisterSlashCommands then
                    CommandSage:RegisterSlashCommands()
                end

                if CommandSage_Config and CommandSage_Config.Get("preferences", "configGuiEnabled") and CommandSage_ConfigGUI then
                    safeCall(CommandSage_ConfigGUI, "InitGUI")
                end

                if CommandSage.HookAllChatFrames then
                    CommandSage:HookAllChatFrames()
                end
            end

        elseif event == "PLAYER_LOGIN" then
            if CommandSage_Config and CommandSage_Config.Get("preferences", "showTutorialOnStartup")
                    and CommandSage_Tutorial then
                safeCall(CommandSage_Tutorial, "ShowTutorialPrompt")
            end
        --elseif event == "ADDON_UNLOADED" then
        --    local unloadedAddon = param
        --    if unloadedAddon and unloadedAddon:lower() == ADDON_NAME:lower() then
        --        if CommandSage_ShellContext and CommandSage_ShellContext.ClearContext then
        --            safeCall(CommandSage_ShellContext, "ClearContext")
        --        end
        --    end
        --end
            -- Removed "ADDON_UNLOADED" branch (not supported in WoW Classic)
        end
    end)
    if not ok then
        safePrint("Error in event " .. event .. ": " .. tostring(err))
    end
end

mainFrame:SetScript("OnEvent", OnEvent)

--------------------------------------------------------------------------------
-- Slash Command Registration
--------------------------------------------------------------------------------
function CommandSage:RegisterSlashCommands()
    SLASH_COMMANDSAGE1 = "/cmdsage"
    SlashCmdList["COMMANDSAGE"] = function(msg)
        local args = { strsplit(" ", msg or "") }
        local cmd = args[1] or ""
        if cmd == "tutorial" then
            safeCall(CommandSage_Tutorial, "ShowTutorialPrompt")
        elseif cmd == "scan" then
            safeCall(CommandSage_Discovery, "ScanAllCommands")
            safePrint("CommandSage: Force re-scan done.")
        elseif cmd == "fallback" then
            safeCall(CommandSage_Fallback, "EnableFallback")
            safePrint("Fallback ON.")
        elseif cmd == "nofallback" then
            safeCall(CommandSage_Fallback, "DisableFallback")
            safePrint("Fallback OFF.")
        elseif cmd == "togglefallback" then
            safeCall(CommandSage_Fallback, "ToggleFallback")
        elseif cmd == "debug" then
            safeCall(CommandSage_DeveloperAPI, "DebugDump")
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
                safePrint("Set config " .. tostring(key) .. " = " .. tostring(val))
            else
                safePrint("Usage: /cmdsage config <key> <value>")
            end
        elseif cmd == "mode" then
            local modeVal = args[2]
            if modeVal == "fuzzy" or modeVal == "strict" then
                CommandSage_Config.Set("preferences", "suggestionMode", modeVal)
                safePrint("Suggestion mode = " .. modeVal)
            else
                safePrint("Usage: /cmdsage mode <fuzzy|strict>")
            end
        elseif cmd == "theme" then
            local themeVal = args[2]
            if themeVal then
                CommandSage_Config.Set("preferences", "uiTheme", themeVal)
                safePrint("UI theme set to " .. tostring(themeVal))
            else
                safePrint("Usage: /cmdsage theme <dark|light|classic>")
            end
        elseif cmd == "scale" then
            local scaleVal = tonumber(args[2])
            if scaleVal then
                CommandSage_Config.Set("preferences", "uiScale", scaleVal)
                safePrint("UI scale set to " .. tostring(scaleVal))
            else
                safePrint("Usage: /cmdsage scale <number>")
            end
        elseif cmd == "gui" then
            safeCall(CommandSage_ConfigGUI, "Toggle")
        elseif cmd == "resetprefs" then
            safeCall(CommandSage_Config, "ResetPreferences")
        elseif cmd == "perf" then
            safeCall(CommandSage_Performance, "ShowDashboard")
        else
            safePrint("|cff00ff00CommandSage Usage:|r")
            safePrint(" /cmdsage tutorial")
            safePrint(" /cmdsage scan")
            safePrint(" /cmdsage fallback/nofallback/togglefallback")
            safePrint(" /cmdsage debug")
            safePrint(" /cmdsage config <key> <value>")
            safePrint(" /cmdsage mode <fuzzy|strict>")
            safePrint(" /cmdsage theme <dark|light|classic>")
            safePrint(" /cmdsage scale <number>")
            safePrint(" /cmdsage resetprefs")
            safePrint(" /cmdsage gui")
            safePrint(" /cmdsage perf")
        end
    end
end

--------------------------------------------------------------------------------
-- Hook Chat Frame EditBox (if needed)
--------------------------------------------------------------------------------
function CommandSage:HookChatFrameEditBox(editBox)
    if not editBox or editBox.CommandSageHooked then
        return
    end

    local boxName = "<unnamed>"
    if type(editBox.GetName) == "function" then
        local nm = editBox:GetName()
        if nm then
            boxName = nm
        end
    end

    local bindingManagerFrame = CreateFrame("Frame", nil)

    local function DisableAllBindings()
        local override = CommandSage_Config.Get("preferences", "overrideHotkeysWhileTyping") or false
        local always = CommandSage_Config.Get("preferences", "alwaysDisableHotkeysInChat") or false
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
        safeCall(CommandSage_KeyBlocker, "BlockKeys")
        local chatHalo = CommandSage_Config.Get("preferences", "chatInputHaloEnabled")
        if chatHalo then
            self:SetBackdropColor(1, 1, 0, 0.2)
        end
    end)

    editBox:HookScript("OnEditFocusLost", function(self)
        pcall(RestoreAllBindings)
        self:SetPropagateKeyboardInput(true)
        safeCall(CommandSage_KeyBlocker, "UnblockKeys")
        local chatHalo = CommandSage_Config.Get("preferences", "chatInputHaloEnabled")
        if chatHalo then
            self:SetBackdropColor(0, 0, 0, 0)
        end
    end)

    local function CloseAutoCompleteOnChatDeactivate()
        safeCall(CommandSage_AutoComplete, "CloseSuggestions")
    end
    hooksecurefunc("ChatEdit_DeactivateChat", CloseAutoCompleteOnChatDeactivate)

    editBox:HookScript("OnKeyDown", function(self, key)
        local advKeybinds = CommandSage_Config.Get("preferences", "advancedKeybinds") or false
        if not advKeybinds then
            self:SetPropagateKeyboardInput(true)
            return
        end
        local text = self:GetText() or ""
        local isSlash = (text:sub(1, 1) == "/")
        local isInShell = false
        if CommandSage_ShellContext and CommandSage_ShellContext.IsActive then
            isInShell = CommandSage_ShellContext:IsActive()
        end
        if isSlash or isInShell then
            self:SetPropagateKeyboardInput(false)
            if key == "UP" then
                if IsShiftKeyDown() then
                    safeCall(CommandSage_AutoComplete, "MoveSelection", -5)
                else
                    safeCall(CommandSage_AutoComplete, "MoveSelection", -1)
                end
                return
            elseif key == "DOWN" then
                if IsShiftKeyDown() then
                    safeCall(CommandSage_AutoComplete, "MoveSelection", 5)
                else
                    safeCall(CommandSage_AutoComplete, "MoveSelection", 1)
                end
                return
            elseif key == "TAB" then
                if IsShiftKeyDown() then
                    safeCall(CommandSage_AutoComplete, "MoveSelection", -1)
                else
                    safeCall(CommandSage_AutoComplete, "AcceptOrAdvance")
                end
                return
            elseif key == "C" and IsControlKeyDown() then
                self:SetText("")
                safeCall(CommandSage_AutoComplete, "CloseSuggestions")
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
        if CommandSage_Fallback and CommandSage_Fallback.IsFallbackActive
                and CommandSage_Fallback:IsFallbackActive()
        then
            return
        end
        local txt = eBox:GetText()
        if txt == "" then
            safeCall(CommandSage_AutoComplete, "CloseSuggestions")
            return
        end
        local firstChar = txt:sub(1, 1)
        local shellActive = false
        if CommandSage_ShellContext and CommandSage_ShellContext.IsActive then
            shellActive = CommandSage_ShellContext:IsActive()
        end
        if firstChar ~= "/" and not shellActive then
            safeCall(CommandSage_AutoComplete, "CloseSuggestions")
            return
        end
        local firstWord = txt:match("^(%S+)")
        local rest = txt:match("^%S+%s+(.*)") or ""
        local paramHints = CommandSage_ParameterHelper:GetParameterSuggestions(firstWord, rest)
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
            CommandSage_AutoComplete:ShowSuggestions(paramSugg)
            return
        end
        local final = CommandSage_AutoComplete:GenerateSuggestions(txt)
        CommandSage_AutoComplete:ShowSuggestions(final)
    end)

    editBox.CommandSageHooked = true
end

--------------------------------------------------------------------------------
-- Hook All Chat Frames
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

CommandSage.frame = mainFrame
debugPrint("Core/CommandSage_Core has finished loading.")

return CommandSage  -- Return the global table we defined
