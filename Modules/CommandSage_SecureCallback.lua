CommandSage_SecureCallback = {}
function CommandSage_SecureCallback:IsCommandProtected(slash)
    if slash == "/console" then
        return true
    end
    return false
end
function CommandSage_SecureCallback:ExecuteCommand(slash, args)
    if self:IsCommandProtected(slash) and InCombatLockdown() then
        print("|cffff0000[CommandSage]|r: Can't run protected command in combat:", slash)
        return
    end
    local disc = CommandSage_Discovery:GetDiscoveredCommands()
    local cmdObj = disc and disc[slash]
    if cmdObj and cmdObj.callback then
        securecall(cmdObj.callback, args or "")
    else
        ChatFrame1EditBox:SetText(slash .. " " .. (args or ""))
        ChatEdit_SendText(ChatFrame1EditBox, 0)
    end
end
function CommandSage_SecureCallback:IsAnyCommandProtected(commandList)
    for _, slash in ipairs(commandList) do
        if self:IsCommandProtected(slash) then
            return true
        end
    end
    return false
end
