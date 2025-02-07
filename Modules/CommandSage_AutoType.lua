-- File: Modules/CommandSage_AutoType.lua
local Config = _G.CommandSage_Config
CommandSage_AutoType = {}
-- Ensure a frame exists for auto-typing
if not CommandSage_AutoType.frame then
    CommandSage_AutoType.frame = CreateFrame("Frame", "CommandSageAutoTypeFrame", UIParent)
end
CommandSage_AutoType.text = ""
CommandSage_AutoType.index = 1
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
    if animate == nil then animate = false end

    if not animate then
        ChatFrame1EditBox:SetText(cmd)
        if self.frame then
            self.frame:SetScript("OnUpdate", nil)
        end
        self.isTyping = false
        return
    end

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
        if self.index <= #self.text then
            local currentText = string.sub(self.text, 1, self.index)
            ChatFrame1EditBox:SetText(currentText)
            self.index = self.index + 1
        else
            ChatFrame1EditBox:SetText(self.text)
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

_G.CommandSage_AutoType = CommandSage_AutoType
return CommandSage_AutoType
