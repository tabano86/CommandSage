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
    print("Discovered commands:", #CommandSage_Discovery:GetDiscoveredCommands())
    print("Usage data entries:", CommandSageDB.usageData and #CommandSageDB.usageData or 0)
    -- etc.
end

function CommandSage_DeveloperAPI:ForceReindex()
    CommandSage_Discovery:ScanAllCommands()
end

function CommandSage_DeveloperAPI:GetAllCommands()
    return CommandSage_Discovery:GetDiscoveredCommands()
end
