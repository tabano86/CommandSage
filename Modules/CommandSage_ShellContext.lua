-- =============================================================================
-- CommandSage_ShellContext.lua
-- Allows a "cd" concept for slash commands. E.g. /cd macro => type "new test"
-- is actually "/macro new test".
-- =============================================================================

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
    -- If user already typed '/', let that take precedence
    if typedText:sub(1, 1) == "/" then
        return typedText
    end
    -- otherwise, rewrite
    if not currentContext or currentContext == "" then
        return typedText
    end
    local slashContext = "/" .. currentContext
    -- combine them
    local combined = slashContext .. " " .. typedText
    return combined
end

function CommandSage_ShellContext:HandleCd(msg)
    if not CommandSage_Config.Get("preferences", "shellContextEnabled") then
        print("Shell context is disabled by config.")
        return
    end

    local target = msg:lower():trim()

    if target == ".." or target == "" then
        currentContext = nil
        print("CommandSage shell context cleared.")
    else
        -- Check if this slash actually exists
        local fullSlash = "/" .. target
        local discovered = CommandSage_Discovery:GetDiscoveredCommands()
        if discovered and discovered[fullSlash] then
            currentContext = target
            print("CommandSage shell context set to '/" .. target .. "'. Type commands without slash.")
        else
            print("No known slash command '" .. fullSlash .. "' found. Context not changed.")
        end
    end
end
