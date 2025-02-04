-- =============================================================================
-- CommandSage_AutoType.lua
-- Animated "typing" effect
-- =============================================================================

CommandSage_AutoType = {}

local frame = CreateFrame("Frame")
frame:Hide()
frame.delay = 0
frame.textToType = ""
frame.index = 0

frame:SetScript("OnUpdate", function(self, elapsed)
    self.delay = self.delay - elapsed
    if self.delay <= 0 then
        self.index = self.index + 1
        local partial = self.textToType:sub(1, self.index)
        ChatFrame1EditBox:SetText(partial)
        ChatFrame1EditBox:SetCursorPosition(#partial)
        self.delay = CommandSage_Config.Get("preferences", "autoTypeDelay") or 0.03
        if self.index >= #self.textToType then
            self:Hide()
        end
    end
end)

function CommandSage_AutoType:BeginAutoType(cmdStr)
    if not CommandSage_Config.Get("preferences", "animateAutoType") then
        ChatFrame1EditBox:SetText(cmdStr)
        ChatFrame1EditBox:SetCursorPosition(#cmdStr)
        return
    end
    frame.textToType = cmdStr
    frame.index = 0
    frame.delay = 0
    frame:Show()
end
