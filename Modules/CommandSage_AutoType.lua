-- File: Modules/CommandSage_AutoType.lua
local Config = _G.CommandSage_Config
CommandSage_AutoType = {}

-- Ensure we have a frame:
if not CommandSage_AutoType.frame then
    CommandSage_AutoType.frame = CreateFrame("Frame", "CommandSageAutoTypeFrame", UIParent)
end

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
    self.timer = 0
    self.isTyping = true

    local animate = Config.Get("preferences", "animateAutoType") or false
    if not animate then
        -- Instantly set the entire text, no OnUpdate needed
        ChatFrame1EditBox:SetText(cmd)
        if self.frame then
            self.frame:SetScript("OnUpdate", nil)
            self.frame:Hide()
        end
        self.isTyping = false
        return
    end

    -- If animateAutoType == true:
    self.index = 0
    ChatFrame1EditBox:SetText("")
    if not self.frame then
        self.frame = CreateFrame("Frame", "CommandSageAutoTypeFrame", UIParent)
    end
    self.frame:Show()
    self.frame:SetScript("OnUpdate", function(frame, elapsed)
        self:OnUpdate(frame, elapsed)
    end)
end

function CommandSage_AutoType:OnUpdate(frame, elapsed)
    if not self.isTyping then return end
    local delay = Config.Get("preferences", "autoTypeDelay") or 0.1
    self.timer = self.timer + elapsed
    if self.timer >= delay then
        self.timer = 0
        -- Start indexing from 0, so we do index+1 each time
        if self.index < #self.text then
            self.index = self.index + 1
            local currentText = string.sub(self.text, 1, self.index)
            ChatFrame1EditBox:SetText(currentText)
        else
            ChatFrame1EditBox:SetText(self.text)
            self:StopAutoType()
        end
    end
end

function CommandSage_AutoType:StopAutoType()
    -- Tests want the final text to remain in the box
    if self.isTyping then
        ChatFrame1EditBox:SetText(self.text)
    end
    if self.frame then
        self.frame:Hide()
        self.frame:SetScript("OnUpdate", nil)
    end
    self.isTyping = false
end

_G.CommandSage_AutoType = CommandSage_AutoType
return CommandSage_AutoType
