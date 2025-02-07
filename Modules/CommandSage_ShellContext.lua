-- File: Modules/CommandSage_ShellContext.lua
-- Refactored shell context module

local ShellContext = {}
-- Initialize with nil so that GetCurrentContext returns nil when not set.
local currentContext = nil

function ShellContext:IsActive()
    if not CommandSage_Config or not CommandSage_Config.Get("preferences", "shellContextEnabled") then
        return false
    end
    return currentContext ~= nil
end

function ShellContext:RewriteInputIfNeeded(typedText)
    if type(typedText) ~= "string" then
        typedText = tostring(typedText or "")
    end
    if not self:IsActive() then
        return typedText
    end
    if typedText:sub(1, 1) == "/" then
        return typedText
    end
    return "/" .. currentContext .. " " .. typedText
end

function ShellContext:HandleCd(msg)
    if not CommandSage_Config or not CommandSage_Config.Get("preferences", "shellContextEnabled") then
        print("Shell context is disabled by config.")
        return
    end
    local target = (msg and msg:match("^%s*(.-)%s*$")) or ""
    if target == "" or target == "clear" or target == "none" or target == ".." then
        currentContext = nil
        print("CommandSage shell context cleared.")
        return
    end
    local fullSlash = "/" .. target
    local discovered = (CommandSage_Discovery and CommandSage_Discovery:GetDiscoveredCommands()) or {}
    if discovered[fullSlash] then
        currentContext = target
        print("CommandSage shell context set to '" .. fullSlash .. "'.")
    else
        print("No known slash command '" .. fullSlash .. "' found. Context not changed.")
    end
end

function ShellContext:GetCurrentContext()
    return currentContext  -- returns nil if not set
end

function ShellContext:ClearContext()
    currentContext = nil
end

return ShellContext
