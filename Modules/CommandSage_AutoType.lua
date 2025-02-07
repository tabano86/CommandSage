-- File: Modules/CommandSage_AutoType.lua
-- Refactored auto-type module that is robust and handles edge cases.

local Config = CommandSage_Config  -- assumed to be available globally
local AutoType = {}

-- Ensure the auto-type frame exists.
if not AutoType.frame then
    AutoType.frame = CreateFrame("Frame", "CommandSageAutoTypeFrame", UIParent)
end

-- Internal state variables.
AutoType.text = ""
AutoType.index = 0
AutoType.timer = 0
AutoType.isTyping = false

--------------------------------------------------------------------------------
-- BeginAutoType: Starts auto-typing the provided command.
-- If animateAutoType is false then the command is immediately set.
--------------------------------------------------------------------------------
function AutoType:BeginAutoType(cmd)
    if type(cmd) ~= "string" or cmd == "" then
        error("Invalid command provided to BeginAutoType")
    end

    -- If already typing, stop the previous auto-type.
    if self.isTyping then
        self:StopAutoType()
    end

    self.text = cmd
    self.timer = 0
    self.isTyping = true

    local animate = Config.Get("preferences", "animateAutoType") or false
    local editBox = _G.ChatFrame1EditBox  -- reference our global stub
    if not animate then
        -- Immediate set: update the text field right away.
        editBox:SetText(cmd)
        editBox.text = cmd  -- ensure our stub's field is updated
        if self.frame then
            self.frame:SetScript("OnUpdate", nil)
            self.frame:Hide()
        end
        self.isTyping = false
        return
    end

    -- Animated mode: reset index and start with empty text.
    self.index = 0
    editBox:SetText("")
    if not self.frame then
        self.frame = CreateFrame("Frame", "CommandSageAutoTypeFrame", UIParent)
    end
    self.frame:Show()
    self.frame:SetScript("OnUpdate", function(frame, elapsed)
        self:OnUpdate(frame, elapsed)
    end)
end

--------------------------------------------------------------------------------
-- OnUpdate: Callback function that adds one character per delay interval.
--------------------------------------------------------------------------------
function AutoType:OnUpdate(frame, elapsed)
    if not self.isTyping then
        return
    end
    local delay = Config.Get("preferences", "autoTypeDelay") or 0.1
    self.timer = self.timer + elapsed
    local editBox = _G.ChatFrame1EditBox
    if self.timer >= delay then
        self.timer = self.timer - delay
        if self.index < #self.text then
            self.index = self.index + 1
            local currentText = self.text:sub(1, self.index)
            editBox:SetText(currentText)
        else
            -- Finished typing; leave the text intact.
            editBox:SetText(self.text)
            self:StopAutoType(true)  -- pass true so it does not clear the text
        end
    end
end

--------------------------------------------------------------------------------
-- StopAutoType: Stops the auto-type process and finalizes the text.
--------------------------------------------------------------------------------
function AutoType:StopAutoType(finalize)
    local editBox = _G.ChatFrame1EditBox
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
end

return AutoType