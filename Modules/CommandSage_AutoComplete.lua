-- =============================================================================
-- CommandSage_AutoComplete.lua
-- Next-decade auto-complete UI with highlight, scrolling, etc.
-- =============================================================================

CommandSage_AutoComplete = {}

local autoCompleteFrame = nil
local scrollFrame = nil
local content = nil
local suggestionButtons = {}
local MAX_SUGGESTIONS = 20 -- bigger by default

local function CreateAutoCompleteFrame()
    if autoCompleteFrame then
        return autoCompleteFrame
    end

    autoCompleteFrame = CreateFrame("Frame", "CommandSageAutoCompleteFrame", UIParent, "BackdropTemplate")
    autoCompleteFrame:SetSize(320, 200)
    autoCompleteFrame:SetPoint("TOPLEFT", ChatFrame1EditBox, "BOTTOMLEFT", 0, -2)
    autoCompleteFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        edgeSize = 16,
        tile = true,
        tileSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    autoCompleteFrame:SetBackdropColor(0, 0, 0, 0.8)
    autoCompleteFrame:Hide()

    scrollFrame = CreateFrame("ScrollFrame", "CommandSageAutoCompleteScroll", autoCompleteFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 5, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", -28, 5)

    content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(1,1)
    scrollFrame:SetScrollChild(content)

    content.buttons = {}
    for i=1, MAX_SUGGESTIONS do
        local btn = CreateFrame("Button", nil, content)
        btn:SetHeight(18)
        btn:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -(i-1)*18)
        btn:SetPoint("RIGHT", content, "RIGHT", 0, 0)

        btn.bg = btn:CreateTexture(nil, "BACKGROUND")
        btn.bg:SetAllPoints()
        btn.bg:SetColorTexture(0.2,0.2,0.2,0.1)
        btn.bg:Hide()

        btn.highlight = btn:CreateTexture(nil, "HIGHLIGHT")
        btn.highlight:SetAllPoints()
        btn.highlight:SetColorTexture(0.5,0.5,0.5,0.3)

        btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        btn.text:SetPoint("LEFT", btn, "LEFT", 4, 0)
        btn.text:SetJustifyH("LEFT")
        btn.text:SetTextColor(1,1,1,1)

        btn:SetScript("OnEnter", function(self)
            self.bg:Show()
        end)
        btn:SetScript("OnLeave", function(self)
            self.bg:Hide()
        end)

        btn:SetScript("OnClick", function(self)
            local slashCmd = self.slashCmd
            if slashCmd then
                if CommandSage_Config.Get("preferences","animateAutoType") then
                    CommandSage_AutoType:BeginAutoType(slashCmd)
                else
                    ChatFrame1EditBox:SetText(slashCmd)
                    ChatFrame1EditBox:SetCursorPosition(#slashCmd)
                end
                -- Add to usage & history
                CommandSage_AdaptiveLearning:IncrementUsage(slashCmd)
                CommandSage_HistoryPlayback:AddToHistory(slashCmd)
            end
            autoCompleteFrame:Hide()
        end)

        btn:Hide()
        content.buttons[i] = btn
    end

    return autoCompleteFrame
end

local function ShowSuggestions(matches)
    local frame = CreateAutoCompleteFrame()
    local maxToShow = math.min(#matches, MAX_SUGGESTIONS)
    local totalHeight = maxToShow * 18

    for i, btn in ipairs(content.buttons) do
        local data = matches[i]
        if data and i <= maxToShow then
            btn.slashCmd = data.slash
            btn.text:SetText(data.slash)
            btn:Show()
        else
            btn.slashCmd = nil
            btn.text:SetText("")
            btn:Hide()
        end
    end
    content:SetHeight(totalHeight)
    frame:SetHeight(math.min(totalHeight + 10, 200)) -- clamp max height
    frame:Show()
end

function CommandSage_AutoComplete:OnTextChanged(editBox, userInput)
    if not userInput then return end
    if CommandSage_Fallback:IsFallbackActive() then return end

    local text = editBox:GetText()
    if text == "" or text:sub(1,1) ~= "/" then
        if autoCompleteFrame then
            autoCompleteFrame:Hide()
        end
        return
    end

    local partialLower = text:lower()
    local possible = CommandSage_Trie:FindPrefix(partialLower)
    local fuzzy = CommandSage_Config.Get("preferences","fuzzyMatchEnabled")
    local matched = {}

    if fuzzy then
        matched = CommandSage_FuzzyMatch:GetSuggestions(partialLower, possible)
    else
        for _, cmdObj in ipairs(possible) do
            table.insert(matched, { slash=cmdObj.slash, data=cmdObj.data, rank=0 })
        end
        table.sort(matched, function(a,b) return a.slash < b.slash end)
    end

    ShowSuggestions(matched)
end

-- Hook after the world is loaded
local hookFrame = CreateFrame("Frame")
hookFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
hookFrame:SetScript("OnEvent", function()
    local editBox = ChatFrame1EditBox
    if editBox then
        local orig = editBox:GetScript("OnTextChanged")
        editBox:SetScript("OnTextChanged", function(eBox, userInput)
            if orig then orig(eBox, userInput) end
            CommandSage_AutoComplete:OnTextChanged(eBox, userInput)
        end)
    end
end)
