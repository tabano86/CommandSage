-- =============================================================================
-- CommandSage_DeveloperAPI.lua
-- Events, debug, forced reindex, etc.
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
    print("Discovered commands:", discovered and #discovered or 0)
    local usageData = CommandSageDB.usageData
    local usageCount = 0
    if usageData then
        for k in pairs(usageData) do usageCount=usageCount+1 end
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
