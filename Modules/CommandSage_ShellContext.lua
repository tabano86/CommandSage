-- Modules/CommandSage_ShellContext.lua
-- Enhanced shell context module for CommandSage

CommandSage_ShellContext = {}
-- Store current context on the module table
CommandSage_ShellContext.currentContext = nil

--------------------------------------------------------------------------------
-- IsActive: Returns true if shell context is enabled in config and a context is set.
--------------------------------------------------------------------------------
function CommandSage_ShellContext:IsActive()
    if not CommandSage_Config.Get("preferences", "shellContextEnabled") then
        return false
    end
    return self.currentContext ~= nil and self.currentContext ~= ""
end

--------------------------------------------------------------------------------
-- RewriteInputIfNeeded: If shell context is active and the input does not already
-- start with a slash, prepend the current context to the input.
--
-- @param typedText (string): The input text typed by the user.
-- @return (string): The potentially rewritten input.
--------------------------------------------------------------------------------
function CommandSage_ShellContext:RewriteInputIfNeeded(typedText)
    -- Ensure typedText is a string.
    if type(typedText) ~= "string" then
        typedText = tostring(typedText or "")
    end
    -- If context is not active, return the text unchanged.
    if not self:IsActive() then
        return typedText
    end
    -- If the text already starts with a slash, do not modify it.
    if typedText:sub(1, 1) == "/" then
        return typedText
    end
    -- If no valid current context is set, return the text unchanged.
    if not self.currentContext or self.currentContext == "" then
        return typedText
    end
    return "/" .. self.currentContext .. " " .. typedText
end

--------------------------------------------------------------------------------
-- HandleCd: Processes a context change command.
--
-- When the provided message is one of "..", "none", "clear", or empty, it clears
-- the current context. Otherwise, it checks the discovered commands for a matching
-- slash command. If found, it sets that as the new context.
--
-- @param msg (string): The command text used to set or clear the context.
--------------------------------------------------------------------------------
function CommandSage_ShellContext:HandleCd(msg)
    if not CommandSage_Config.Get("preferences", "shellContextEnabled") then
        print("Shell context is disabled by config.")
        return
    end
    -- Ensure msg is a string.
    if type(msg) ~= "string" then
        msg = tostring(msg)
    end
    local target = msg:lower():trim()
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

--------------------------------------------------------------------------------
-- GetCurrentContext: Returns the current shell context.
--
-- @return (string or nil): The currently active shell context or nil if none.
--------------------------------------------------------------------------------
function CommandSage_ShellContext:GetCurrentContext()
    return self.currentContext
end

--------------------------------------------------------------------------------
-- ClearContext: Explicitly clears the shell context.
--------------------------------------------------------------------------------
function CommandSage_ShellContext:ClearContext()
    self.currentContext = nil
end

return CommandSage_ShellContext
