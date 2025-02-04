-- =============================================================================
-- CommandSage_HistoryPlayback.lua
-- Stores and replays recent commands
-- =============================================================================

CommandSage_HistoryPlayback = {}

local history = {}
local maxHistorySize = 50

function CommandSage_HistoryPlayback:AddToHistory(commandStr)
    table.insert(history, commandStr)
    if #history > maxHistorySize then
        table.remove(history, 1)
    end
end

function CommandSage_HistoryPlayback:GetHistory()
    return history
end

SLASH_COMMANDSAGEHISTORY1 = "/cmdsagehistory"
SlashCmdList["COMMANDSAGEHISTORY"] = function(msg)
    print("Recent Commands:")
    for i, cmd in ipairs(history) do
        print(string.format("%d) %s", i, cmd))
    end
end
