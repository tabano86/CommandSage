-- File: Modules/CommandSage_AdaptiveLearning.lua
CommandSage_AdaptiveLearning = {}

local function EnsureUsageData()
    if not CommandSageDB or type(CommandSageDB) ~= "table" then
        CommandSageDB = {}
    end
    if not CommandSageDB.usageData or type(CommandSageDB.usageData) ~= "table" then
        CommandSageDB.usageData = {}
    end
end

function CommandSage_AdaptiveLearning:IncrementUsage(slash)
    EnsureUsageData()
    -- Remove slash:lower(), so we store the exact key the user typed:
    CommandSageDB.usageData[slash] = (CommandSageDB.usageData[slash] or 0) + 1
end

function CommandSage_AdaptiveLearning:GetUsageScore(slash)
    EnsureUsageData()
    -- Also remove .lower() here:
    return CommandSageDB.usageData[slash] or 0
end

function CommandSage_AdaptiveLearning:ResetUsageData()
    if not CommandSageDB or type(CommandSageDB) ~= "table" then
        CommandSageDB = {}
    end
    CommandSageDB.usageData = nil
    print("CommandSage: All usage data has been cleared.")
end

return CommandSage_AdaptiveLearning
