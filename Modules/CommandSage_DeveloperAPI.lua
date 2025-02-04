-- =============================================================================
-- CommandSage_DeveloperAPI.lua
-- Provides events, debug info, external plugin registration
-- =============================================================================

CommandSage_DeveloperAPI = {}

local callbacks = {}

function CommandSage_DeveloperAPI:FireEvent(eventName, ...)
    if callbacks[eventName] then
        for _, fn in ipairs(callbacks[eventName]) do
            pcall(fn, ...)
        end
    end
end

function CommandSage_DeveloperAPI:Subscribe(eventName, fn)
    if not callbacks[eventName] then
        callbacks[eventName] = {}
    end
    table.insert(callbacks[eventName], fn)
end

function CommandSage_DeveloperAPI:DebugDump()
    print("== CommandSage Debug Info ==")
    local discovered = CommandSage_Discovery:GetDiscoveredCommands()
    local cmdCount = 0
    if discovered then
        for _ in pairs(discovered) do
            cmdCount = cmdCount + 1
        end
    end
    print("Discovered commands:", cmdCount)

    local usageData = CommandSageDB.usageData
    local usageCount = 0
    if usageData then
        for _ in pairs(usageData) do
            usageCount = usageCount + 1
        end
    end
    print("Usage data entries:", usageCount)

    local hist = CommandSageDB.commandHistory
    print("History entries:", hist and #hist or 0)
end

function CommandSage_DeveloperAPI:ForceReindex()
    CommandSage_Discovery:ScanAllCommands()
end

function CommandSage_DeveloperAPI:GetAllCommands()
    return CommandSage_Discovery:GetDiscoveredCommands()
end

function CommandSage_DeveloperAPI:RegisterCommand(slash, callback, description, category)
    if not slash or slash == "" then return end
    local discovered = CommandSage_Discovery:GetDiscoveredCommands()
    local lowerSlash = slash:lower()

    discovered[lowerSlash] = {
        slash       = lowerSlash,
        callback    = callback or function(msg)
            print("No callback defined for:", slash)
        end,
        source      = "ExternalPlugin",
        description = description or "",
        category    = category or "plugin"
    }
    CommandSage_Trie:InsertCommand(lowerSlash, discovered[lowerSlash])
    self:FireEvent("COMMANDS_UPDATED")
end

function CommandSage_DeveloperAPI:UnregisterCommand(slash)
    if not slash or slash == "" then return end
    local discovered = CommandSage_Discovery:GetDiscoveredCommands()
    local lowerSlash = slash:lower()

    if discovered[lowerSlash] then
        discovered[lowerSlash] = nil
        CommandSage_Trie:RemoveCommand(lowerSlash)
        self:FireEvent("COMMANDS_UPDATED")
    end
end
