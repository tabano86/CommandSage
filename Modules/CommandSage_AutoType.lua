-- CommandSage_AutoType.lua
local CommandSage_Config = require("CommandSage_Config")
local CommandSage_AutoType = {}

-- Create or reference the frame (for example, a hidden UI frame)
CommandSage_AutoType.frame = CommandSage_AutoType.frame or CreateFrame("Frame", "CommandSageAutoTypeFrame", UIParent)
CommandSage_AutoType.text   = ""
CommandSage_AutoType.index  = 0
CommandSage_AutoType.timer  = 0
CommandSage_AutoType.isTyping = false

-- Begins the auto-typing process for the given command string.
function CommandSage_AutoType:BeginAutoType(cmd)
    -- Validate input.
    if type(cmd) ~= "string" or cmd == "" then
        error("Invalid command provided to BeginAutoType")
    end

    -- If an auto-type is already in progress, stop it first.
    if self.isTyping then
        self:StopAutoType()
    end

    self.text  = cmd
    self.index = 1
    self.timer = 0
    self.isTyping = true

    local animate = CommandSage_Config.Get("preferences", "animateAutoType")
    if not animate then
        -- When animation is disabled, immediately set the full text.
        ChatFrame1EditBox:SetText(cmd)
        if self.frame then
            self.frame:SetScript("OnUpdate", nil)
        end
        self.isTyping = false
        return
    end

    -- Animated mode: clear text and start incremental typing.
    ChatFrame1EditBox:SetText("")
    if self.frame then
        self.frame:Show()
        self.frame:SetScript("OnUpdate", function(frame, elapsed)
            self:OnUpdate(frame, elapsed)
        end)
    end
end

-- Internal update function called on each frame update when animating.
function CommandSage_AutoType:OnUpdate(frame, elapsed)
    -- Retrieve the delay from config (with fallback)
    local delay = CommandSage_Config.Get("preferences", "autoTypeDelay") or 0.1
    self.timer = self.timer + elapsed
    if self.timer >= delay then
        self.timer = 0
        if self.index <= #self.text then
            local currentText = string.sub(self.text, 1, self.index)
            ChatFrame1EditBox:SetText(currentText)
            self.index = self.index + 1
        else
            -- Once all characters are typed, stop the auto-type.
            self:StopAutoType()
        end
    end
end

-- Stops any ongoing auto-typing process.
function CommandSage_AutoType:StopAutoType()
    if self.frame then
        self.frame:Hide()
        self.frame:SetScript("OnUpdate", nil)
    end
    self.isTyping = false
end

return CommandSage_AutoType
