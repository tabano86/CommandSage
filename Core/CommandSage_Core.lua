-- File: Core/CommandSage_Core.lua
local ADDON_NAME = "CommandSage"
CommandSage = {}
_G["CommandSage"] = CommandSage

local mainFrame = CreateFrame("Frame", "CommandSageMainFrame", UIParent)
mainFrame:RegisterEvent("ADDON_LOADED")
mainFrame:RegisterEvent("PLAYER_LOGIN")
mainFrame:RegisterEvent("PLAYER_LOGOUT")

CommandSage.debugMode = true  -- ENABLE DEBUGGING

local function debugPrint(msg)
    if CommandSage.debugMode then
        print("|cff999999[CommandSage-Debug]|r", msg)
    end
end

local function safePrint(msg)
    print("[CommandSage]: " .. tostring(msg))
end

local function safeCall(mod, methodName, ...)
    if not mod or type(mod[methodName]) ~= "function" then
        debugPrint("Method " .. tostring(methodName) .. " not available.")
        return false
    end
    local ok, err = pcall(mod[methodName], mod, ...)
    if not ok then
        debugPrint("Error calling " .. methodName .. ": " .. tostring(err))
        return false
    end
    return true
end

if not string.trim then
    function string:trim() return self:match("^%s*(.-)%s*$") end
end

if not strsplit then
    function strsplit(delimiter, text)
        local list = {}
        for token in string.gmatch(text, "[^" .. delimiter .. "]+") do
            table.insert(list, token)
        end
        return unpack(list)
    end
end

CommandSage.coreConfigInitialized = false

local debugTimer = 0
mainFrame:SetScript("OnUpdate", function(_, elapsed)
    if CommandSage.debugMode then
        debugTimer = debugTimer + elapsed
        if debugTimer >= 60 then
            local memKB = collectgarbage("count")
            debugPrint("Memory Usage: " .. string.format("%.2f MB", memKB/1024))
            debugTimer = 0
        end
    end
end)

local function OnEvent(_, event, param)
    local ok, err = pcall(function()
        if event == "ADDON_LOADED" then
            if param and param:lower() == ADDON_NAME:lower() then
                if CommandSage_Config and CommandSage_Config.InitializeDefaults then
                    CommandSage_Config:InitializeDefaults()
                    CommandSage.coreConfigInitialized = true
                    debugPrint("Config defaults initialized.")
                else
                    safePrint("Error: Config.InitializeDefaults not available.")
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
            if CommandSage_Config and CommandSage_Config.Get("preferences", "showTutorialOnStartup") and CommandSage_Tutorial then
                safeCall(CommandSage_Tutorial, "ShowTutorialPrompt")
            end

        elseif event == "PLAYER_LOGOUT" then
            safeCall(CommandSage_PersistentTrie, "SaveTrie")
            local memKB = collectgarbage("count")
            safePrint("Logging out. Final memory usage: " .. string.format("%.2f MB", memKB/1024))
        end
    end)
    if not ok then
        safePrint("Error in event " .. event .. ": " .. tostring(err))
    end
end

mainFrame:SetScript("OnEvent", OnEvent)

-- Hook chat edit boxes
function CommandSage:HookChatFrameEditBox(editBox)
    if not editBox or editBox.CommandSageHooked then return end

    -- Ensure arrow keys are delivered to our handler.
    editBox:SetAltArrowKeyMode(false)
    editBox:EnableKeyboard(true)

    local bindingFrame = CreateFrame("Frame", nil)

    local function DisableAllBindings()
        local override = CommandSage_Config.Get("preferences", "overrideHotkeysWhileTyping") or false
        local always = CommandSage_Config.Get("preferences", "alwaysDisableHotkeysInChat") or false
        if not override and not always then return end
        for i = 1, GetNumBindings() do
            local _, key1, key2 = GetBinding(i)
            if key1 then SetOverrideBinding(bindingFrame, true, key1, nil) end
            if key2 then SetOverrideBinding(bindingFrame, true, key2, nil) end
        end
    end

    local function RestoreAllBindings()
        ClearOverrideBindings(bindingFrame)
    end

    editBox:HookScript("OnEditFocusGained", function(self)
        pcall(DisableAllBindings)
        safeCall(CommandSage_KeyBlocker, "BlockKeys")
        self:SetPropagateKeyboardInput(false)
        if CommandSage_Config.Get("preferences", "chatInputHaloEnabled") and self.SetBackdropColor then
            self:SetBackdropColor(1, 1, 0, 0.2)
        end
    end)
    editBox:HookScript("OnEditFocusLost", function(self)
        pcall(RestoreAllBindings)
        safeCall(CommandSage_KeyBlocker, "UnblockKeys")
        self:SetPropagateKeyboardInput(true)
        if CommandSage_Config.Get("preferences", "chatInputHaloEnabled") and self.SetBackdropColor then
            self:SetBackdropColor(0, 0, 0, 0)
        end
    end)

    hooksecurefunc("ChatEdit_DeactivateChat", function() safeCall(CommandSage_AutoComplete, "CloseSuggestions") end)

    -- Add an OnKeyDown hook to intercept arrow keys immediately.
    editBox:HookScript("OnKeyDown", function(self, key)
        if key == "UP" or key == "DOWN" or key == "LEFT" or key == "RIGHT" then
            -- Block propagation of arrow keys so character movement does not occur.
            self:SetPropagateKeyboardInput(false)
            return
        end
    end)

    -- Use OnKeyUp for our custom navigation.
    editBox:HookScript("OnKeyUp", function(self, key)
        debugPrint("OnKeyUp: key = " .. key)
        local advKeybinds = CommandSage_Config.Get("preferences", "advancedKeybinds") or false
        if not advKeybinds then
            self:SetPropagateKeyboardInput(true)
            return
        end

        local text = self:GetText() or ""
        local isSlash = (text:sub(1, 1) == "/")
        local shellActive = CommandSage_ShellContext and CommandSage_ShellContext:IsActive() or false
        if isSlash or shellActive then
            self:SetPropagateKeyboardInput(false)
            local shift = IsShiftKeyDown()
            local ctrl  = IsControlKeyDown()
            if key == "UP" then
                debugPrint("Key UP pressed")
                if CommandSage_AutoComplete and CommandSage_AutoComplete:IsVisible() then
                    safeCall(CommandSage_AutoComplete, "MoveSelection", shift and -5 or -1)
                else
                    local prev = CommandSage_HistoryPlayback:GetPreviousHistory()
                    if prev then
                        self:SetText(prev)
                        self:SetCursorPosition(#prev)
                    end
                end
                return
            elseif key == "DOWN" then
                debugPrint("Key DOWN pressed")
                if CommandSage_AutoComplete and CommandSage_AutoComplete:IsVisible() then
                    safeCall(CommandSage_AutoComplete, "MoveSelection", shift and 5 or 1)
                else
                    local nxt = CommandSage_HistoryPlayback:GetNextHistory()
                    if nxt then
                        self:SetText(nxt)
                        self:SetCursorPosition(#nxt)
                    end
                end
                return
            elseif key:upper() == "TAB" then
                debugPrint("Key TAB pressed, shift = " .. tostring(shift))
                if CommandSage_AutoComplete then
                    safeCall(CommandSage_AutoComplete, "OnTabPress", shift)
                end
                return
            elseif key == "C" and ctrl then
                self:SetText("")
                safeCall(CommandSage_AutoComplete, "CloseSuggestions")
                return
            end
        else
            self:SetPropagateKeyboardInput(true)
        end
    end)

    local origTextChanged = editBox:GetScript("OnTextChanged")
    editBox:SetScript("OnTextChanged", function(eBox, userInput)
        if origTextChanged then pcall(origTextChanged, eBox, userInput) end
        if not userInput then return end
        if CommandSage_Fallback and CommandSage_Fallback:IsFallbackActive() then return end
        local txt = eBox:GetText()
        if txt == "" then
            safeCall(CommandSage_AutoComplete, "CloseSuggestions")
            return
        end
        if txt:sub(1, 1) ~= "/" and not (CommandSage_ShellContext and CommandSage_ShellContext:IsActive()) then
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
            CommandSage_AutoComplete:ShowSuggestions(paramSugg, txt)
            return
        end
        local final = CommandSage_AutoComplete:GenerateSuggestions(txt)
        CommandSage_AutoComplete:ShowSuggestions(final, txt)
    end)

    editBox.CommandSageHooked = true
end

function CommandSage:HookAllChatFrames()
    for i = 1, NUM_CHAT_WINDOWS do
        local cf = _G["ChatFrame" .. i]
        if cf and cf.editBox then
            self:HookChatFrameEditBox(cf.editBox)
        end
    end
end

debugPrint("Core/CommandSage_Core has finished loading.")
return CommandSage
