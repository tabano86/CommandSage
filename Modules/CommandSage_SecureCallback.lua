-- Modules/CommandSage_SecureCallback.lua
CommandSage_SecureCallback = {}

function CommandSage_SecureCallback:IsCommandProtected(slash)
    if slash == "/console" then
        return true
    end
    return false
end

function CommandSage_SecureCallback:ExecuteCommand(slash, args)
    if not slash or slash == "" then return end
    if self:IsCommandProtected(slash) and InCombatLockdown() then
        -- unify the exact string so the test sees it
        print("Can't run protected command in combat: " .. slash)
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
