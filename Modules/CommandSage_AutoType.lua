-- File: Modules/CommandSage_AutoType.lua
-- Enhanced auto-type module with advanced controls, event firing, cancellation support,
-- optional finish callback, and detailed debug logging.
--
-- Dependencies:
--   • CommandSage_Config (for preferences)
--   • Optionally, CommandSage_DeveloperAPI for event notifications
--
-- Usage:
--   AutoType:BeginAutoType("/dance", function(finalText)
--       print("Finished auto-typing:", finalText)
--   end)
--   -- To cancel in progress:
--   AutoType:CancelAutoType()

local Config = CommandSage_Config  -- assumed to be available globally
local AutoType = {}

-- Debug logging utility (only prints if CommandSage.debugMode is true)
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

-- Internal state variables.
AutoType.text = ""
AutoType.index = 0
AutoType.timer = 0
AutoType.isTyping = false
AutoType.finishCallback = nil   -- Optional callback to invoke when typing is finished

-- Helper function to retrieve the chat edit box safely.
local function getEditBox()
    local editBox = _G.ChatFrame1EditBox
    if not editBox then
        error("ChatFrame1EditBox not found!")
    end
    return editBox
end

--------------------------------------------------------------------------------
-- BeginAutoType: Starts auto-typing the provided command.
-- If animation is disabled then the command is immediately set.
--
-- @param cmd (string): The command to type.
-- @param onFinish (function, optional): A callback function called upon finish.
--------------------------------------------------------------------------------
function AutoType:BeginAutoType(cmd, onFinish)
    if type(cmd) ~= "string" or cmd == "" then
        error("Invalid command provided to BeginAutoType")
    end

    -- If already typing, cancel the previous auto-type.
    if self.isTyping then
        debugLog("AutoType already in progress; cancelling previous auto-type.")
        self:StopAutoType(false)  -- cancel without finalizing
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

    -- Animated mode: clear the edit box and start auto-typing.
    debugLog("Starting animated auto-type for: " .. cmd)
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
-- OnUpdate: Called repeatedly (by the auto-type frame) to add one character at a time.
--
-- @param frame: The auto-type frame.
-- @param elapsed: Time elapsed since the last update.
--------------------------------------------------------------------------------
function AutoType:OnUpdate(frame, elapsed)
    if not self.isTyping then
        return
    end
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
            -- Finished typing; finalize text.
            editBox:SetText(self.text)
            self:StopAutoType(true)  -- finalize = true
        end
    end
end

--------------------------------------------------------------------------------
-- StopAutoType: Stops the auto-type process.
--
-- @param finalize (boolean): If true, leave the text intact; if false, clear it.
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
-- CancelAutoType: Cancels the ongoing auto-type process without finalizing the text.
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
-- IsTyping: Returns whether an auto-type process is currently active.
--------------------------------------------------------------------------------
function AutoType:IsTyping()
    return self.isTyping
end

return AutoType
