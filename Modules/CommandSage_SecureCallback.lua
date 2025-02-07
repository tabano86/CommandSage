-- File: Modules/CommandSage_SecureCallback.lua
-- Refactored secure callback module for executing slash commands safely.
local SecureCallback = {}

-- Define a lookup table for protected commands.
local protectedCommands = {
    ["/console"] = true,
}

-- Returns true if the given command is protected.
function SecureCallback:IsCommandProtected(slash)
    if type(slash) ~= "string" then
        return false
    end
    return protectedCommands[slash] or false
end

-- Executes the slash command if allowed. If the command is protected and the user is in combat,
-- an error message is printed. Otherwise, if a callback exists in the discovered commands, it is
-- invoked securely; if not, the command is sent to the chat edit box.
function SecureCallback:ExecuteCommand(slash, args)
    if type(slash) ~= "string" or slash == "" then
        return
    end

    if self:IsCommandProtected(slash) and InCombatLockdown() then
        print("Can't run protected command in combat: " .. slash)
        return
    end

    local discovered = CommandSage_Discovery:GetDiscoveredCommands() or {}
    local cmdObj = discovered[slash]
    if cmdObj and type(cmdObj.callback) == "function" then
        securecall(cmdObj.callback, args or "")
    else
        local input = slash .. " " .. (args or "")
        ChatFrame1EditBox:SetText(input)
        ChatEdit_SendText(ChatFrame1EditBox, 0)
    end
end

-- Checks a list of commands and returns true if any is protected.
function SecureCallback:IsAnyCommandProtected(commandList)
    if type(commandList) ~= "table" then
        return false
    end
    for _, slash in ipairs(commandList) do
        if self:IsCommandProtected(slash) then
            return true
        end
    end
    return false
end

return SecureCallback
