-- File: Modules/CommandSage_HistoryPlayback.lua
CommandSage_HistoryPlayback = {}
local maxHist = 200
local currentHistoryIndex = 0

local function EnsureHistoryDB()
    if not CommandSageDB or type(CommandSageDB) ~= "table" then
        CommandSageDB = {}
    end
    if type(CommandSageDB.commandHistory) ~= "table" then
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

function CommandSage_HistoryPlayback:GetPreviousHistory()
    EnsureHistoryDB()
    local hist = CommandSageDB.commandHistory or {}
    local count = #hist
    if count == 0 then return nil end
    if currentHistoryIndex <= 1 then
        currentHistoryIndex = count
    else
        currentHistoryIndex = currentHistoryIndex - 1
    end
    return hist[currentHistoryIndex]
end

function CommandSage_HistoryPlayback:GetNextHistory()
    EnsureHistoryDB()
    local hist = CommandSageDB.commandHistory or {}
    local count = #hist
    if count == 0 then return nil end
    if currentHistoryIndex >= count then
        currentHistoryIndex = 1
    else
        currentHistoryIndex = currentHistoryIndex + 1
    end
    return hist[currentHistoryIndex]
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
    if CommandSageDB then
        CommandSageDB.commandHistory = {}
    end
    print("CommandSage: Command history cleared.")
end

return CommandSage_HistoryPlayback
