-- Modules/CommandSage_ShellContext.lua
CommandSage_ShellContext = {}
local currentContext = nil

function CommandSage_ShellContext:IsActive()
    if not CommandSage_Config.Get("preferences", "shellContextEnabled") then
        return false
    end
    return currentContext ~= nil
end

function CommandSage_ShellContext:RewriteInputIfNeeded(typedText)
    if not self:IsActive() then
        return typedText
    end
    if typedText:sub(1, 1) == "/" then
        return typedText
    end
    if not currentContext or currentContext == "" then
        return typedText
    end
    return "/" .. currentContext .. " " .. typedText
end

function CommandSage_ShellContext:HandleCd(msg)
    if not CommandSage_Config.Get("preferences", "shellContextEnabled") then
        print("Shell context is disabled by config.")
        return
    end
    local target = (msg:lower() or ""):trim()
    if target == ".." or target == "none" or target == "clear" or target == "" then
        currentContext = nil
        print("CommandSage shell context cleared.")
    else
        local fullSlash = "/" .. target
        local discovered = CommandSage_Discovery:GetDiscoveredCommands()
        if discovered and discovered[fullSlash] then
            currentContext = target
            print("CommandSage shell context set to '" .. fullSlash .. "'.")
        else
            -- unify the error message so the test sees exactly:
            print("No known slash command '" .. fullSlash .. "' found. Context not changed.")
        end
    end
end

function CommandSage_ShellContext:GetCurrentContext()
    return currentContext
end
