-- =============================================================================
-- CommandSage_SecureCallback.lua
-- Demonstrates how we might ensure secure execution for certain commands
-- =============================================================================

CommandSage_SecureCallback = {}

function CommandSage_SecureCallback:ExecuteCommand(slash, args)
    if InCombatLockdown() then
        print("Cannot run protected command in combat.")
        return
    end
    local cmdObj = CommandSage_Discovery:GetDiscoveredCommands()[slash]
    if cmdObj and cmdObj.callback then
        securecall(cmdObj.callback, args)
    else
        ChatFrame1EditBox:SetText(slash.." "..(args or ""))
        ChatEdit_SendText(ChatFrame1EditBox, 0)
    end
end
