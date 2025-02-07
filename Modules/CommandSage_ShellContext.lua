-- File: Modules/CommandSage_ShellContext.lua
-- Refactored Shell Context handler
local ShellContext = {}

-- Internal current context stored as a local variable.
local currentContext = nil

-- Returns whether shell context is active.
function ShellContext:IsActive()
    if not CommandSage_Config.Get("preferences", "shellContextEnabled") then
        return false
    end
    return currentContext and currentContext ~= ""
end

-- Rewrites the user’s typed text by prepending the current context if active.
function ShellContext:RewriteInputIfNeeded(input)
    if type(input) ~= "string" then
        input = tostring(input or "")
    end
    if not self:IsActive() then
        return input
    end
    -- If the user already typed a slash, do not modify.
    if input:sub(1, 1) == "/" then
        return input
    end
    return "/" .. currentContext .. " " .. input
end

-- Handles the /cd (change directory) command.
function ShellContext:HandleCd(msg)
    if not CommandSage_Config.Get("preferences", "shellContextEnabled") then
        print("Shell context is disabled by config.")
        return
    end

    local target = msg and msg:match("^%s*(.-)%s*$") or ""
    if target == "" or target == "clear" or target == "none" or target == ".." then
        currentContext = nil
        print("CommandSage shell context cleared.")
        return
    end

    local fullSlash = "/" .. target
    local discovered = CommandSage_Discovery:GetDiscoveredCommands() or {}
    if discovered[fullSlash] then
        currentContext = target
        print("CommandSage shell context set to '" .. fullSlash .. "'.")
    else
        print("No known slash command '" .. fullSlash .. "' found. Context not changed.")
    end
end

function ShellContext:GetCurrentContext()
    return currentContext
end

function ShellContext:ClearContext()
    currentContext = nil
end

return ShellContext
