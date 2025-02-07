-- File: Modules/CommandSage_ShellContext.lua
-- Refactored shell context module

local ShellContext = {}

-- Use a local variable to store the current context.
local currentContext = ""

-- Returns whether shell context is active.
function ShellContext:IsActive()
    if not CommandSage_Config or not CommandSage_Config.Get("preferences", "shellContextEnabled") then
        return false
    end
    return currentContext ~= nil and currentContext ~= ""
end

-- If context is active and the user did not start with a slash, prepend the current context.
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

-- Handle the /cd command.
function ShellContext:HandleCd(msg)
    if not CommandSage_Config or not CommandSage_Config.Get("preferences", "shellContextEnabled") then
        print("Shell context is disabled by config.")
        return
    end

    local target = (msg and msg:match("^%s*(.-)%s*$")) or ""
    if target == "" or target == "clear" or target == "none" or target == ".." then
        currentContext = ""
        print("CommandSage shell context cleared.")
        return
    end

    local fullSlash = "/" .. target
    local discovered = CommandSage_Discovery and CommandSage_Discovery:GetDiscoveredCommands() or {}
    if discovered[fullSlash] then
        currentContext = target
        print("CommandSage shell context set to '" .. fullSlash .. "'.")
    else
        print("No known slash command '" .. fullSlash .. "' found. Context not changed.")
    end
end

function ShellContext:GetCurrentContext()
    return (currentContext == "") and nil or currentContext
end

function ShellContext:ClearContext()
    currentContext = ""
end

return ShellContext
