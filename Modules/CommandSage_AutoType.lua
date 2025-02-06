local Config = _G.CommandSage_Config
local CommandSage_AutoType = {}

-- If this file is responsible for creating the hidden UI frame:
CommandSage_AutoType.frame = CommandSage_AutoType.frame or CreateFrame("Frame", "CommandSageAutoTypeFrame", UIParent)
CommandSage_AutoType.text = ""
CommandSage_AutoType.index = 0
CommandSage_AutoType.timer = 0
CommandSage_AutoType.isTyping = false

function CommandSage_AutoType:BeginAutoType(cmd)
    if type(cmd) ~= "string" or cmd == "" then
        error("Invalid command provided to BeginAutoType")
    end

    if self.isTyping then
        self:StopAutoType()
    end

    self.text = cmd
    self.index = 1
    self.timer = 0
    self.isTyping = true

    local animate = Config.Get("preferences", "animateAutoType")
    if not animate then
        -- Immediately set full text if animation is disabled
        ChatFrame1EditBox:SetText(cmd)
        if self.frame then
            self.frame:SetScript("OnUpdate", nil)
        end
        self.isTyping = false
        return
    end

    -- Animated typing mode
    ChatFrame1EditBox:SetText("")
    if self.frame then
        self.frame:Show()
        self.frame:SetScript("OnUpdate", function(frame, elapsed)
            self:OnUpdate(frame, elapsed)
        end)
    end
end

function CommandSage_AutoType:OnUpdate(frame, elapsed)
    local delay = Config.Get("preferences", "autoTypeDelay") or 0.1
    self.timer = self.timer + elapsed
    if self.timer >= delay then
        self.timer = 0
        if self.index <= #self.text then
            local currentText = string.sub(self.text, 1, self.index)
            ChatFrame1EditBox:SetText(currentText)
            self.index = self.index + 1
        else
            self:StopAutoType()
        end
    end
end

function CommandSage_AutoType:StopAutoType()
    if self.frame then
        self.frame:Hide()
        self.frame:SetScript("OnUpdate", nil)
    end
    self.isTyping = false
end

-- Expose globally (the loader also does require(...), so that's fine).
_G.CommandSage_AutoType = CommandSage_AutoType
return CommandSage_AutoType
