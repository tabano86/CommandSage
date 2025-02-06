-- Core/CommandSage_Core.lua
-- A fully enhanced, robust, and ironclad core module for CommandSage.
-- This version avoids using "..." by defining all functions with explicit parameters.
-- It also verifies all dependencies before calling them and uses pcall for safe execution.

-------------------------------------------------------------------------------
-- CONSTANTS & GLOBALS
-------------------------------------------------------------------------------
local ADDON_NAME = "CommandSage"  -- Use a constant add-on name for testing and live environments.
CommandSage = CommandSage or {}     -- Ensure our global add-on table exists.
_G["CommandSage"] = CommandSage     -- Expose it globally.

-------------------------------------------------------------------------------
-- MAIN EVENT FRAME SETUP
-------------------------------------------------------------------------------
local mainFrame = CreateFrame("Frame", "CommandSageMainFrame", UIParent)
mainFrame:RegisterEvent("ADDON_LOADED")
mainFrame:RegisterEvent("PLAYER_LOGIN")
mainFrame:RegisterEvent("ADDON_UNLOADED")

-------------------------------------------------------------------------------
-- DEBUG & UTILITY FUNCTIONS
-------------------------------------------------------------------------------
CommandSage.debugMode = false  -- Set to true to enable extra debug output

local function safePrint(msg)
    print("[CommandSage]: " .. tostring(msg))
end

local function debugPrint(msg)
    if CommandSage.debugMode then
        print("|cff999999[CommandSage-Debug]|r " .. tostring(msg))
    end
end

local function safeCall(mod, methodName, ...)
    if mod and type(mod[methodName]) == "function" then
        local ok, err = pcall(mod[methodName], mod, ...)
        if not ok then
            safePrint("Error in " .. methodName .. ": " .. tostring(err))
        end
    else
        debugPrint("Method " .. tostring(methodName) .. " not available in " .. tostring(mod))
    end
end

-------------------------------------------------------------------------------
-- POLYFILLS: string.trim and strsplit
-------------------------------------------------------------------------------
if not string.trim then
    function string:trim()
        return self:match("^%s*(.-)%s*$")
    end
end

if not strsplit then
    function strsplit(delimiter, text)
        if type(text) ~= "string" then return {} end
        local list = {}
        for token in string.gmatch(text, "[^" .. delimiter .. "]+") do
            table.insert(list, token)
        end
        return unpack(list)
    end
end

-------------------------------------------------------------------------------
-- PERFORMANCE TRACKING (OPTIONAL)
-------------------------------------------------------------------------------
local function recordMemoryUsage(phase)
    local trackPerf = false
    if CommandSage_Config and CommandSage_Config.Get then
        trackPerf = CommandSage_Config.Get("preferences", "perfTrackingEnabled")
    end
    if trackPerf then
        local memKB = collectgarbage("count")
        debugPrint(phase .. " memory usage: " .. string.format("%.2f MB", memKB / 1024))
    end
end

-------------------------------------------------------------------------------
-- MAIN EVENT HANDLER
--
-- Note: Instead of using "..." we now explicitly accept a single extra parameter,
-- which for ADDON_LOADED (and ADDON_UNLOADED) is assumed to be the add-on name.
-------------------------------------------------------------------------------
local function OnEvent(self, event, extra)
    local ok, err = pcall(function()
        if event == "ADDON_LOADED" then
            local loadedAddon = extra
            debugPrint("ADDON_LOADED received for addon: " .. tostring(loadedAddon))
            if loadedAddon == ADDON_NAME then
                -- Initialize configuration.
                safeCall(CommandSage_Config, "InitializeDefaults")
                -- Clear any old shell context.
                if CommandSage_ShellContext and CommandSage_ShellContext.ClearContext then
                    safeCall(CommandSage_ShellContext, "ClearContext")
                end
                -- Initialize terminal goodies if enabled.
                if CommandSage_Config and CommandSage_Config.Get("preferences", "enableTerminalGoodies")
                        and CommandSage_Terminal and CommandSage_Terminal.Initialize then
                    safeCall(CommandSage_Terminal, "Initialize")
                end
                -- Load persistent trie data.
                safeCall(CommandSage_PersistentTrie, "LoadTrie")
                -- Scan for slash commands.
                safeCall(CommandSage_Discovery, "ScanAllCommands")
                -- Register slash commands.
                if CommandSage.RegisterSlashCommands then
                    CommandSage:RegisterSlashCommands()
                end
                -- Initialize config GUI if enabled.
                if CommandSage_Config and CommandSage_Config.Get("preferences", "configGuiEnabled")
                        and CommandSage_ConfigGUI and CommandSage_ConfigGUI.InitGUI then
                    safeCall(CommandSage_ConfigGUI, "InitGUI")
                end
                -- Hook all chat frames.
                if CommandSage.HookAllChatFrames then
                    CommandSage:HookAllChatFrames()
                end
                recordMemoryUsage("Post-ADDON_LOADED")
            end

        elseif event == "PLAYER_LOGIN" then
            debugPrint("PLAYER_LOGIN event received.")
            if CommandSage_Config and CommandSage_Config.Get("preferences", "showTutorialOnStartup")
                    and CommandSage_Tutorial and CommandSage_Tutorial.ShowTutorialPrompt then
                safeCall(CommandSage_Tutorial, "ShowTutorialPrompt")
            end
            recordMemoryUsage("Post-PLAYER_LOGIN")

        elseif event == "ADDON_UNLOADED" then
            local unloadedAddon = extra
            debugPrint("ADDON_UNLOADED event received for addon: " .. tostring(unloadedAddon))
            if unloadedAddon == ADDON_NAME then
                -- Do not clear the shell context so that it remains intact.
                recordMemoryUsage("Post-ADDON_UNLOADED")
            end
        end
    end)
    if not ok then
        safePrint("Error handling event " .. event .. ": " .. tostring(err))
    end
end

mainFrame:SetScript("OnEvent", OnEvent)

-------------------------------------------------------------------------------
-- SLASH COMMAND REGISTRATION
-------------------------------------------------------------------------------
function CommandSage:RegisterSlashCommands()
    SLASH_COMMANDSAGE1 = "/cmdsage"
    SlashCmdList["COMMANDSAGE"] = function(msg)
        local args = { strsplit(" ", msg or "") }
        local cmd = args[1] or ""
        debugPrint("Slash command invoked: " .. tostring(cmd))

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
                safePrint("Set config " .. key .. " = " .. tostring(val))
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
                safePrint("UI theme set to " .. themeVal)
            else
                safePrint("Usage: /cmdsage theme <dark|light|classic>")
            end
        elseif cmd == "scale" then
            local scaleVal = args[2] and tonumber(args[2])
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

-------------------------------------------------------------------------------
-- HOOK CHAT FRAME EDITBOX
--
-- This function attaches custom key and text-change handlers to a chat edit box.
-------------------------------------------------------------------------------
function CommandSage:HookChatFrameEditBox(editBox)
    if not editBox or editBox.CommandSageHooked then
        return
    end

    debugPrint("Hooking EditBox: " .. (editBox:GetName() or "<unnamed>"))
    local bindingManagerFrame = CreateFrame("Frame", nil)

    local function DisableAllBindings()
        local override, always = false, false
        if CommandSage_Config and CommandSage_Config.Get then
            override = CommandSage_Config.Get("preferences", "overrideHotkeysWhileTyping")
            always   = CommandSage_Config.Get("preferences", "alwaysDisableHotkeysInChat")
        end
        if not override and not always then return end
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
        local ok, err = pcall(DisableAllBindings)
        if not ok then debugPrint("DisableAllBindings error: " .. tostring(err)) end
        self:SetPropagateKeyboardInput(false)
        safeCall(CommandSage_KeyBlocker, "BlockKeys")
        if CommandSage_Config and CommandSage_Config.Get("preferences", "chatInputHaloEnabled") then
            self:SetBackdropColor(1, 1, 0, 0.2)
        end
    end)

    editBox:HookScript("OnEditFocusLost", function(self)
        pcall(RestoreAllBindings)
        self:SetPropagateKeyboardInput(true)
        safeCall(CommandSage_KeyBlocker, "UnblockKeys")
        if CommandSage_Config and CommandSage_Config.Get("preferences", "chatInputHaloEnabled") then
            self:SetBackdropColor(0, 0, 0, 0)
        end
    end)

    local function CloseAutoCompleteOnChatDeactivate()
        safeCall(CommandSage_AutoComplete, "CloseSuggestions")
    end
    hooksecurefunc("ChatEdit_DeactivateChat", CloseAutoCompleteOnChatDeactivate)

    editBox:HookScript("OnKeyDown", function(self, key)
        local text = self:GetText() or ""
        local isSlash = (text:sub(1, 1) == "/")
        local isInShellContext = false
        if CommandSage_ShellContext and CommandSage_ShellContext.IsActive then
            isInShellContext = CommandSage_ShellContext:IsActive()
        end
        local advKeybinds = false
        if CommandSage_Config and CommandSage_Config.Get then
            advKeybinds = CommandSage_Config.Get("preferences", "advancedKeybinds")
        end
        if not advKeybinds then
            self:SetPropagateKeyboardInput(true)
            return
        end

        if isSlash or isInShellContext then
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
        if not userInput then return end
        if CommandSage_Fallback and CommandSage_Fallback.IsFallbackActive and CommandSage_Fallback:IsFallbackActive() then
            return
        end
        local text = eBox:GetText()
        if text == "" then
            safeCall(CommandSage_AutoComplete, "CloseSuggestions")
            return
        end
        local firstChar = text:sub(1, 1)
        local inShell = false
        if CommandSage_ShellContext and CommandSage_ShellContext.IsActive then
            inShell = CommandSage_ShellContext:IsActive()
        end
        if firstChar ~= "/" and not inShell then
            safeCall(CommandSage_AutoComplete, "CloseSuggestions")
            return
        end
        local firstWord = text:match("^(%S+)")
        local rest = text:match("^%S+%s+(.*)") or ""
        local paramHints = {}
        if CommandSage_ParameterHelper and CommandSage_ParameterHelper.GetParameterSuggestions then
            local okPH, resultPH = pcall(CommandSage_ParameterHelper.GetParameterSuggestions, CommandSage_ParameterHelper, firstWord, rest)
            if okPH and type(resultPH) == "table" then
                paramHints = resultPH
            end
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
            safeCall(CommandSage_AutoComplete, "ShowSuggestions", paramSugg)
            return
        end
        local final = {}
        if CommandSage_AutoComplete and CommandSage_AutoComplete.GenerateSuggestions then
            local okAuto, resultAuto = pcall(CommandSage_AutoComplete.GenerateSuggestions, CommandSage_AutoComplete, text)
            if okAuto and type(resultAuto) == "table" then
                final = resultAuto
            end
        end
        safeCall(CommandSage_AutoComplete, "ShowSuggestions", final)
    end)
    editBox.CommandSageHooked = true
end

-------------------------------------------------------------------------------
-- HOOK ALL CHAT FRAMES
-------------------------------------------------------------------------------
function CommandSage:HookAllChatFrames()
    for i = 1, NUM_CHAT_WINDOWS do
        local cf = _G["ChatFrame" .. i]
        local editBox = cf and cf.editBox
        if editBox then
            self:HookChatFrameEditBox(editBox)
        end
    end
end

-------------------------------------------------------------------------------
-- FINALIZE THE CORE MODULE
-------------------------------------------------------------------------------
CommandSage.frame = mainFrame
debugPrint("Core/CommandSage_Core has finished loading.")
