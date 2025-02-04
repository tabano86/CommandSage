-- =============================================================================
-- CommandSage_HistoryPlayback.lua
-- Stores and replays recent commands (persisting across sessions)
-- =============================================================================

CommandSage_HistoryPlayback = {}

local maxHistorySize = 100

local function EnsureHistoryDB()
    if not CommandSageDB.commandHistory then
        CommandSageDB.commandHistory = {}
    end
end

function CommandSage_HistoryPlayback:AddToHistory(commandStr)
    EnsureHistoryDB()
    table.insert(CommandSageDB.commandHistory, commandStr)
    if #CommandSageDB.commandHistory > maxHistorySize then
        table.remove(CommandSageDB.commandHistory, 1)
    end
end

function CommandSage_HistoryPlayback:GetHistory()
    EnsureHistoryDB()
    return CommandSageDB.commandHistory
end

SLASH_COMMANDSAGEHISTORY1 = "/cmdsagehistory"
SlashCmdList["COMMANDSAGEHISTORY"] = function(msg)
    print("Recent Commands (persisted):")
    local hist = CommandSage_HistoryPlayback:GetHistory()
    for i, cmd in ipairs(hist) do
        print(string.format("%d) %s", i, cmd))
    end
end
