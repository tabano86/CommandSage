-- =============================================================================
-- CommandSage_SecureCallback.lua
-- Demonstrates how we might ensure secure execution for certain commands
-- =============================================================================

CommandSage_SecureCallback = {}

function CommandSage_SecureCallback:ExecuteCommand(slash, args)
    -- If slash modifies protected functions in combat, we might do something like:
    if InCombatLockdown() then
        -- Possibly queue the command or deny it
        print("Cannot run protected command in combat.")
        return
    end
    -- Otherwise, call the slash callback if we know it, or fallback to normal
    local cmdObj = CommandSage_Discovery:GetDiscoveredCommands()[slash]
    if cmdObj and cmdObj.callback then
        -- We can't do actual "securecall" unless it's a known safe function
        securecall(cmdObj.callback, args)
    else
        -- fallback
        ChatFrame1EditBox:SetText(slash .. " " .. (args or ""))
        ChatEdit_SendText(ChatFrame1EditBox, 0)
    end
end
