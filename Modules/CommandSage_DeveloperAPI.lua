-- =============================================================================
-- CommandSage_DeveloperAPI.lua
-- Provides external integration points, event firing, debug, etc.
-- =============================================================================

CommandSage_DeveloperAPI = {}

local callbacks = {}

function CommandSage_DeveloperAPI:FireEvent(eventName, ...)
    if not callbacks[eventName] then return end
    for _, fn in ipairs(callbacks[eventName]) do
        pcall(fn, ...)
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
    print("Trie node count:", CommandSage_Performance:CountTrieNodes())
    local discovered = CommandSage_Discovery:GetDiscoveredCommands()
    print("Discovered commands:", discovered and #discovered or 0)
    if CommandSageDB.usageData then
        local usageCount = 0
        for _ in pairs(CommandSageDB.usageData) do usageCount=usageCount+1 end
        print("Usage data entries:", usageCount)
    else
        print("Usage data entries: 0")
    end
    local hist = CommandSageDB.commandHistory
    print("Persisted History entries:", hist and #hist or 0)
end

function CommandSage_DeveloperAPI:ForceReindex()
    CommandSage_Discovery:ScanAllCommands()
end

function CommandSage_DeveloperAPI:GetAllCommands()
    return CommandSage_Discovery:GetDiscoveredCommands()
end
