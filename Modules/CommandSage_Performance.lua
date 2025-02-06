CommandSage_Performance = {}
local perfFrame = nil
function CommandSage_Performance:ShowDashboard()
    if perfFrame and perfFrame:IsShown() then
        perfFrame:Hide()
        return
    end
    if not perfFrame then
        perfFrame = CreateFrame("Frame", "CommandSagePerfFrame", UIParent, "BasicFrameTemplate")
        perfFrame:SetSize(360, 220)
        perfFrame:SetPoint("CENTER")
        perfFrame.TitleText:SetText("CommandSage Performance")
        local fs = perfFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        fs:SetPoint("TOPLEFT", 15, -30)
        fs:SetWidth(330)
        fs:SetText("")
        perfFrame.statsText = fs
    end
    local text = "Trie Nodes: " .. self:CountTrieNodes() .. "\n"
    local discovered = CommandSage_Discovery:GetDiscoveredCommands()
    local count = 0
    for _ in pairs(discovered) do
        count = count + 1
    end
    text = text .. "Discovered commands: " .. count .. "\n"
    local memKB = collectgarbage("count")
    text = text .. string.format("Addon Memory: %.2f MB\n", memKB / 1024)
    perfFrame.statsText:SetText(text)
    perfFrame:Show()
end
function CommandSage_Performance:CountTrieNodes()
    local function count(node)
        local total = 1
        for _, child in pairs(node.children) do
            total = total + count(child)
        end
        return total
    end
    return count(CommandSage_Trie:GetRoot())
end
function CommandSage_Performance:PrintDetailedStats()
    print("=== CommandSage Detailed Stats ===")
    print("Total Trie Nodes:", self:CountTrieNodes())
    local discovered = CommandSage_Discovery:GetDiscoveredCommands()
    local c = 0
    for _ in pairs(discovered) do
        c = c + 1
    end
    print("Discovered commands:", c)
    print("Memory (MB):", string.format("%.2f", collectgarbage("count") / 1024))
end
