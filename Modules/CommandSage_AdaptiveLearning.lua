CommandSage_AdaptiveLearning = {}
local function EnsureUsageData()
    if type(CommandSageDB) ~= "table" then
        CommandSageDB = {}
    end
    if type(CommandSageDB.usageData) ~= "table" then
        CommandSageDB.usageData = {}
    end
end
function CommandSage_AdaptiveLearning:IncrementUsage(slash)
    EnsureUsageData()
    local key = slash:lower()
    CommandSageDB.usageData[key] = (CommandSageDB.usageData[key] or 0) + 1
end
function CommandSage_AdaptiveLearning:GetUsageScore(slash)
    EnsureUsageData()
    return CommandSageDB.usageData[slash:lower()] or 0
end
function CommandSage_AdaptiveLearning:ResetUsageData()
    if type(CommandSageDB) ~= "table" then
        CommandSageDB = {}
    end
    CommandSageDB.usageData = nil
    print("CommandSage: All usage data has been cleared.")
end

return CommandSage_AdaptiveLearning
