-- =============================================================================
-- CommandSage_Performance.lua
-- Displays or logs performance stats for debugging
-- =============================================================================

CommandSage_Performance = {}

local perfFrame = nil

function CommandSage_Performance:ShowDashboard()
    if perfFrame and perfFrame:IsShown() then
        perfFrame:Hide()
        return
    end
    if not perfFrame then
        perfFrame = CreateFrame("Frame", "CommandSagePerfFrame", UIParent, "BasicFrameTemplate")
        perfFrame:SetSize(300, 200)
        perfFrame:SetPoint("CENTER")
        perfFrame.TitleText:SetText("CommandSage Performance")

        local fs = perfFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        fs:SetPoint("TOPLEFT", 15, -30)
        fs:SetWidth(270)
        fs:SetJustifyH("LEFT")
        fs:SetText("Collecting stats...")

        perfFrame.statsText = fs
    end

    local statsText = ""
    statsText = statsText .. "Trie Nodes: " .. CommandSage_Performance:CountTrieNodes() .. "\n"
    statsText = statsText .. "Cached Commands: " .. #CommandSage_Discovery:GetDiscoveredCommands() .. "\n"
    statsText = statsText .. "(More metrics could go here...)"

    perfFrame.statsText:SetText(statsText)
    perfFrame:Show()
end

function CommandSage_Performance:CountTrieNodes()
    local function countNodes(node)
        local sum = 1
        for _, child in pairs(node.children) do
            sum = sum + countNodes(child)
        end
        return sum
    end
    return countNodes(CommandSage_Trie:GetRoot())
end
