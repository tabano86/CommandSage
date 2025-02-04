-- =============================================================================
-- CommandSage_AutoType.lua
-- Simulates typing out the command for a fun, visual effect
-- =============================================================================

CommandSage_AutoType = {}

local typingFrame = CreateFrame("Frame")
typingFrame:Hide()
typingFrame.delay = 0
typingFrame.textToType = ""
typingFrame.currentIndex = 0

typingFrame:SetScript("OnUpdate", function(self, elapsed)
    self.delay = self.delay - elapsed
    if self.delay <= 0 then
        self.currentIndex = self.currentIndex + 1
        local partial = self.textToType:sub(1, self.currentIndex)
        ChatFrame1EditBox:SetText(partial)
        ChatFrame1EditBox:SetCursorPosition(#partial)
        self.delay = CommandSage_Config.Get("preferences", "autoTypeDelay") or 0.05
        if self.currentIndex >= #self.textToType then
            self:Hide()
        end
    end
end)

function CommandSage_AutoType:BeginAutoType(fullCommand)
    if not CommandSage_Config.Get("preferences", "animateAutoType") then
        -- Just set the text instantly
        ChatFrame1EditBox:SetText(fullCommand)
        ChatFrame1EditBox:SetCursorPosition(#fullCommand)
        return
    end

    typingFrame.textToType = fullCommand
    typingFrame.currentIndex = 0
    typingFrame.delay = 0
    typingFrame:Show()
end
