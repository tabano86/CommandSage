-- File: Modules/CommandSage_AutoType.lua
-- Refactored auto-type module
local Config = CommandSage_Config  -- assumed to be available globally
local AutoType = {}

-- Ensure the auto-type frame exists.
if not AutoType.frame then
    AutoType.frame = CreateFrame("Frame", "CommandSageAutoTypeFrame", UIParent)
end

AutoType.text = ""
AutoType.index = 0
AutoType.timer = 0
AutoType.isTyping = false

-- Begins auto-typing a command.
function AutoType:BeginAutoType(cmd)
    if type(cmd) ~= "string" or cmd == "" then
        error("Invalid command provided to BeginAutoType")
    end

    -- If already typing, stop first.
    if self.isTyping then
        self:StopAutoType()
    end

    self.text = cmd
    self.timer = 0
    self.isTyping = true

    local animate = Config.Get("preferences", "animateAutoType") or false
    if not animate then
        ChatFrame1EditBox:SetText(cmd)
        if self.frame then
            self.frame:SetScript("OnUpdate", nil)
            self.frame:Hide()
        end
        self.isTyping = false
        return
    end

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

-- OnUpdate callback that types the command character-by-character.
function AutoType:OnUpdate(frame, elapsed)
    if not self.isTyping then return end
    local delay = Config.Get("preferences", "autoTypeDelay") or 0.1
    self.timer = self.timer + elapsed
    if self.timer >= delay then
        self.timer = self.timer - delay
        if self.index < #self.text then
            self.index = self.index + 1
            local currentText = self.text:sub(1, self.index)
            ChatFrame1EditBox:SetText(currentText)
        else
            ChatFrame1EditBox:SetText(self.text)
            self:StopAutoType()
        end
    end
end

-- Stops auto-typing and ensures the full command is in the edit box.
function AutoType:StopAutoType()
    if self.isTyping then
        ChatFrame1EditBox:SetText(self.text)
    end
    if self.frame then
        self.frame:Hide()
        self.frame:SetScript("OnUpdate", nil)
    end
    self.isTyping = false
end

_G.CommandSage_AutoType = AutoType
return AutoType
