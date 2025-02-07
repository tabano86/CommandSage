-- File: Modules/CommandSage_SecureCallback.lua
-- Refactored secure callback module
local SecureCallback = {}

local protectedCommands = {
    ["/console"] = true,
}

function SecureCallback:IsCommandProtected(slash)
    if type(slash) ~= "string" then return false end
    return protectedCommands[slash] or false
end

function SecureCallback:ExecuteCommand(slash, args)
    if type(slash) ~= "string" or slash == "" then
        return
    end
    if self:IsCommandProtected(slash) and InCombatLockdown and InCombatLockdown() then
        print("Can't run protected command in combat: " .. slash)
        return
    end
    local discovered = CommandSage_Discovery and CommandSage_Discovery:GetDiscoveredCommands() or {}
    local cmdObj = discovered[slash]
    if cmdObj and type(cmdObj.callback) == "function" then
        securecall(cmdObj.callback, args or "")
    else
        local input = slash .. " " .. (args or "")
        ChatFrame1EditBox:SetText(input)
        ChatEdit_SendText(ChatFrame1EditBox, 0)
    end
end

function SecureCallback:IsAnyCommandProtected(commandList)
    if type(commandList) ~= "table" then return false end
    for _, slash in ipairs(commandList) do
        if self:IsCommandProtected(slash) then
            return true
        end
    end
    return false
end

return SecureCallback
