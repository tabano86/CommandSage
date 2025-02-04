-- =============================================================================
-- CommandSage_Performance.lua
-- Shows performance or debug stats
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
        perfFrame:SetSize(320, 200)
        perfFrame:SetPoint("CENTER")
        perfFrame.TitleText:SetText("CommandSage Performance")

        local fs = perfFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        fs:SetPoint("TOPLEFT", 15, -30)
        fs:SetWidth(290)
        fs:SetText("")
        perfFrame.statsText = fs
    end

    local text = "Trie Nodes: " .. self:CountTrieNodes() .. "\n"
    local discovered = CommandSage_Discovery:GetDiscoveredCommands()
    text = text .. "Discovered commands: " .. (discovered and #discovered or 0) .. "\n"
    perfFrame.statsText:SetText(text)
    perfFrame:Show()
end

function CommandSage_Performance:CountTrieNodes()
    local function count(node)
        local total = 1
        for c, child in pairs(node.children) do
            total = total + count(child)
        end
        return total
    end
    return count(CommandSage_Trie:GetRoot())
end
