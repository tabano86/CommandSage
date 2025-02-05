CommandSage_AdaptiveLearning = {}
local function EnsureUsageData()
    if not CommandSageDB.usageData then
        CommandSageDB.usageData={}
    end
end
function CommandSage_AdaptiveLearning:IncrementUsage(slash)
    EnsureUsageData()
    CommandSageDB.usageData[slash]=(CommandSageDB.usageData[slash] or 0)+1
end
function CommandSage_AdaptiveLearning:GetUsageScore(slash)
    EnsureUsageData()
    return CommandSageDB.usageData[slash] or 0
end
function CommandSage_AdaptiveLearning:ResetUsageData()
    CommandSageDB.usageData=nil
    print("CommandSage: All usage data has been cleared.")
end
