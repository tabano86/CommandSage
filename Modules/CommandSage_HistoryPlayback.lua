CommandSage_HistoryPlayback = {}
local maxHist = 200
local function EnsureHistoryDB()
    if not CommandSageDB.commandHistory then
        CommandSageDB.commandHistory = {}
    end
end
function CommandSage_HistoryPlayback:AddToHistory(cmd)
    if not CommandSage_Config.Get("preferences", "persistHistory") then
        return
    end
    EnsureHistoryDB()
    table.insert(CommandSageDB.commandHistory, cmd)
    if #CommandSageDB.commandHistory > maxHist then
        table.remove(CommandSageDB.commandHistory, 1)
    end
end
function CommandSage_HistoryPlayback:GetHistory()
    EnsureHistoryDB()
    return CommandSageDB.commandHistory
end
SLASH_COMMANDSAGEHISTORY1 = "/cmdsagehistory"
SlashCmdList["COMMANDSAGEHISTORY"] = function(msg)
    print("|cff00ff00CommandSage History|r:")
    local hist = CommandSage_HistoryPlayback:GetHistory()
    for i, c in ipairs(hist) do
        print(string.format("%3d) %s", i, c))
    end
end
SLASH_SEARCHHISTORY1 = "/searchhistory"
SlashCmdList["SEARCHHISTORY"] = function(msg)
    local query = msg:lower()
    local hist = CommandSage_HistoryPlayback:GetHistory()
    print("|cff00ff00History Search for:|r", msg)
    for i, c in ipairs(hist) do
        if c:lower():find(query, 1, true) then
            print(string.format("%3d) %s", i, c))
        end
    end
end
SLASH_CLEARHISTORY1 = "/clearhistory"
SlashCmdList["CLEARHISTORY"] = function(msg)
    CommandSageDB.commandHistory = {}
    print("CommandSage: Command history cleared.")
end
