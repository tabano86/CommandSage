-- File: Modules/CommandSage_AutoType.lua
-- Enhanced auto-type module with advanced controls, event firing, cancellation support,
-- optional finish callback, and detailed debug logging.
--
-- Usage:
--   AutoType:BeginAutoType("/dance", function(finalText)
--       print("Finished auto-typing:", finalText)
--   end)
--   -- To cancel in progress:
--   AutoType:CancelAutoType()

local Config = CommandSage_Config  -- assumed global
local AutoType = {}

local function debugLog(msg)
    if CommandSage and CommandSage.debugMode then
        print("|cff999999[AutoType Debug]|r", msg)
    end
end

-- Ensure the auto-type frame exists.
if not AutoType.frame then
    AutoType.frame = CreateFrame("Frame", "CommandSageAutoTypeFrame", UIParent, "BackdropTemplate")
    AutoType.frame:Hide()
end

-- Internal state.
AutoType.text = ""
AutoType.index = 0
AutoType.timer = 0
AutoType.isTyping = false
AutoType.finishCallback = nil  -- optional finish callback

-- Helper: get ChatFrame1EditBox (error if not found)
local function getEditBox()
    local editBox = _G.ChatFrame1EditBox
    if not editBox then
        error("ChatFrame1EditBox not found!")
    end
    return editBox
end

--------------------------------------------------------------------------------
-- BeginAutoType: starts auto-typing the provided command.
-- If animation is off then the command is immediately inserted.
--------------------------------------------------------------------------------
function AutoType:BeginAutoType(cmd, onFinish)
    if type(cmd) ~= "string" or cmd == "" then
        error("Invalid command provided to BeginAutoType")
    end

    -- If already typing, cancel previous process.
    if self.isTyping then
        debugLog("AutoType already in progress; cancelling previous auto-type.")
        self:StopAutoType(false)
    end

    -- Close any active auto-complete suggestions.
    if CommandSage_AutoComplete and CommandSage_AutoComplete.CloseSuggestions then
        CommandSage_AutoComplete:CloseSuggestions()
    end

    self.text = cmd
    self.index = 0
    self.timer = 0
    self.isTyping = true
    self.finishCallback = onFinish

    local animate = Config.Get("preferences", "animateAutoType") or false
    local editBox = getEditBox()

    if not animate then
        debugLog("Animation disabled; setting text immediately.")
        editBox:SetText(cmd)
        if self.frame then
            self.frame:SetScript("OnUpdate", nil)
            self.frame:Hide()
        end
        self.isTyping = false
        if self.finishCallback and type(self.finishCallback) == "function" then
            pcall(self.finishCallback, cmd)
        end
        if CommandSage_DeveloperAPI and CommandSage_DeveloperAPI.FireEvent then
            CommandSage_DeveloperAPI:FireEvent("AUTO_TYPE_FINISHED", cmd)
        end
        return
    end

    debugLog("Starting animated auto-type for: " .. cmd)
    -- Clear the edit box and start animation.
    editBox:SetText("")
    self.frame:Show()
    self.frame:SetScript("OnUpdate", function(frame, elapsed)
        self:OnUpdate(frame, elapsed)
    end)
    if CommandSage_DeveloperAPI and CommandSage_DeveloperAPI.FireEvent then
        CommandSage_DeveloperAPI:FireEvent("AUTO_TYPE_STARTED", cmd)
    end
end

--------------------------------------------------------------------------------
-- OnUpdate: Called repeatedly (by the auto-type frame) to add one character.
--------------------------------------------------------------------------------
function AutoType:OnUpdate(frame, elapsed)
    if not self.isTyping then return end
    local delay = Config.Get("preferences", "autoTypeDelay") or 0.1
    self.timer = self.timer + elapsed
    local editBox = getEditBox()
    if self.timer >= delay then
        self.timer = self.timer - delay
        if self.index < #self.text then
            self.index = self.index + 1
            local currentText = self.text:sub(1, self.index)
            editBox:SetText(currentText)
            debugLog("AutoType progress: " .. currentText)
        else
            editBox:SetText(self.text)
            self:StopAutoType(true)  -- finalize
        end
    end
end

--------------------------------------------------------------------------------
-- StopAutoType: stops the auto-type process.
--------------------------------------------------------------------------------
function AutoType:StopAutoType(finalize)
    local editBox = getEditBox()
    if self.isTyping then
        if not finalize then
            editBox:SetText("")
        end
    end
    if self.frame then
        self.frame:Hide()
        self.frame:SetScript("OnUpdate", nil)
    end
    self.isTyping = false
    debugLog("AutoType stopped. Finalize: " .. tostring(finalize))
    if finalize and self.finishCallback and type(self.finishCallback) == "function" then
        pcall(self.finishCallback, self.text)
    end
    if CommandSage_DeveloperAPI and CommandSage_DeveloperAPI.FireEvent then
        CommandSage_DeveloperAPI:FireEvent("AUTO_TYPE_FINISHED", self.text)
    end
end

--------------------------------------------------------------------------------
-- CancelAutoType: Cancels the current auto-type process.
--------------------------------------------------------------------------------
function AutoType:CancelAutoType()
    if self.isTyping then
        debugLog("AutoType cancelled.")
        self:StopAutoType(false)
        if CommandSage_DeveloperAPI and CommandSage_DeveloperAPI.FireEvent then
            CommandSage_DeveloperAPI:FireEvent("AUTO_TYPE_CANCELLED")
        end
    end
end

--------------------------------------------------------------------------------
-- IsTyping: Returns whether auto-type is in progress.
--------------------------------------------------------------------------------
function AutoType:IsTyping()
    return self.isTyping
end

return AutoType
