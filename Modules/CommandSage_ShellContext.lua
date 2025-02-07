-- File: Modules/CommandSage_ShellContext.lua
CommandSage_ShellContext = {}
CommandSage_ShellContext.currentContext = nil

function CommandSage_ShellContext:IsActive()
    if not CommandSage_Config.Get("preferences", "shellContextEnabled") then
        return false
    end
    return self.currentContext ~= nil and self.currentContext ~= ""
end

function CommandSage_ShellContext:RewriteInputIfNeeded(typedText)
    if type(typedText) ~= "string" then
        typedText = tostring(typedText or "")
    end
    if not self:IsActive() then
        return typedText
    end
    if typedText:sub(1, 1) == "/" then
        return typedText
    end
    if not self.currentContext or self.currentContext == "" then
        return typedText
    end
    return "/" .. self.currentContext .. " " .. typedText
end

function CommandSage_ShellContext:HandleCd(msg)
    if not CommandSage_Config.Get("preferences", "shellContextEnabled") then
        print("Shell context is disabled by config.")
        return
    end
    local target = (msg and msg:match("^%s*(.-)%s*$")) or ""
    if target == ".." or target == "none" or target == "clear" or target == "" then
        self.currentContext = nil
        print("CommandSage shell context cleared.")
    else
        local fullSlash = "/" .. target
        local discovered = CommandSage_Discovery:GetDiscoveredCommands() or {}
        if discovered[fullSlash] then
            self.currentContext = target
            print("CommandSage shell context set to '" .. fullSlash .. "'.")
        else
            print("No known slash command '" .. fullSlash .. "' found. Context not changed.")
        end
    end
end

function CommandSage_ShellContext:GetCurrentContext()
    return self.currentContext
end

function CommandSage_ShellContext:ClearContext()
    self.currentContext = nil
end

return CommandSage_ShellContext
