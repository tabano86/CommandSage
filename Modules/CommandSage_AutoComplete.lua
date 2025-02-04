-- =============================================================================
-- CommandSage_AutoComplete.lua
-- The “next-decade” UI: scrollable, arrow keys, context filtering, etc.
-- =============================================================================

CommandSage_AutoComplete = {}

local autoFrame, scrollFrame, content
local selectedIndex = 0
local suggestionButtons = {}
local MAX_SUGGEST = 20

-- Example snippet templates
local snippetTemplates = {
    { slash = "/macro", desc = "Create a new macro", snippet = "/macro new <macroName>" },
    { slash = "/dance", desc = "Fancy dance snippet", snippet = "/dance fancy" },
}

local function CreateAutoCompleteUI()
    if autoFrame then
        return autoFrame
    end

    autoFrame = CreateFrame("Frame", "CommandSageAutoCompleteFrame", UIParent, "BackdropTemplate")
    autoFrame:SetSize(350, 250)
    autoFrame:SetPoint("TOPLEFT", ChatFrame1EditBox, "BOTTOMLEFT", 0, -2)
    autoFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tileSize = 16,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    autoFrame:SetBackdropColor(0, 0, 0, 0.9)
    autoFrame:Hide()

    scrollFrame = CreateFrame("ScrollFrame", "CommandSageAutoScroll", autoFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 5, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", -28, 5)

    content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(1, 1)
    scrollFrame:SetScrollChild(content)
    content.buttons = {}

    for i = 1, MAX_SUGGEST do
        local btn = CreateFrame("Button", nil, content)
        btn:SetHeight(20)
        btn:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -(i - 1) * 20)
        btn:SetPoint("RIGHT", content, "RIGHT", 0, 0)

        btn.bg = btn:CreateTexture(nil, "BACKGROUND")
        btn.bg:SetAllPoints()
        btn.bg:SetColorTexture(0.3, 0.3, 0.3, 0.1)
        btn.bg:Hide()

        btn.highlight = btn:CreateTexture(nil, "HIGHLIGHT")
        btn.highlight:SetAllPoints()
        btn.highlight:SetColorTexture(0.6, 0.6, 0.6, 0.3)

        btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        btn.text:SetPoint("LEFT", 5, 0)
        btn.text:SetJustifyH("LEFT")

        btn.info = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        btn.info:SetPoint("RIGHT", -5, 0)
        btn.info:SetJustifyH("RIGHT")
        btn.info:SetTextColor(0.8, 0.8, 0.8, 1)

        btn:SetScript("OnEnter", function(self)
            self.bg:Show()
        end)
        btn:SetScript("OnLeave", function(self)
            self.bg:Hide()
        end)
        btn:SetScript("OnClick", function(self)
            CommandSage_AutoComplete:AcceptSuggestion(self.suggestionData)
        end)

        btn:Hide()
        content.buttons[i] = btn
    end

    return autoFrame
end

-- Keyboard navigation
local function MoveSelection(delta)
    local frame = CreateAutoCompleteUI()
    local totalShown = 0
    for i, b in ipairs(content.buttons) do
        if b:IsShown() then
            totalShown = totalShown + 1
        end
    end
    if totalShown == 0 then
        return
    end

    selectedIndex = selectedIndex + delta
    if selectedIndex < 1 then
        selectedIndex = totalShown
    end
    if selectedIndex > totalShown then
        selectedIndex = 1
    end

    -- highlight the selected one
    for i, b in ipairs(content.buttons) do
        if i == selectedIndex then
            b.bg:Show()
        else
            b.bg:Hide()
        end
    end
end

function CommandSage_AutoComplete:AcceptSuggestion(sugg)
    local slashCmd = sugg.slash
    if slashCmd then
        if CommandSage_Config.Get("preferences", "animateAutoType") then
            CommandSage_AutoType:BeginAutoType(slashCmd)
        else
            ChatFrame1EditBox:SetText(slashCmd)
            ChatFrame1EditBox:SetCursorPosition(#slashCmd)
        end
        -- usage track
        CommandSage_AdaptiveLearning:IncrementUsage(slashCmd)
        CommandSage_HistoryPlayback:AddToHistory(slashCmd)
    end
    autoFrame:Hide()
end

function CommandSage_AutoComplete:ShowSuggestions(suggestions)
    local frame = CreateAutoCompleteUI()
    if #suggestions == 0 then
        frame:Hide()
        return
    end

    local maxShow = math.min(#suggestions, MAX_SUGGEST)
    local btnHeight = 20
    local totalHeight = maxShow * btnHeight
    content:SetHeight(totalHeight)

    for i, btn in ipairs(content.buttons) do
        local s = suggestions[i]
        if i <= maxShow and s then
            btn.suggestionData = s
            local usageScore = CommandSage_AdaptiveLearning:GetUsageScore(s.slash)
            local freqDisplay = usageScore > 0 and ("(" .. usageScore .. ")") or ""
            local cat = CommandSage_CommandOrganizer:GetCategory(s.slash)
            local desc = s.data and s.data.description or ""
            btn.text:SetText(s.slash .. " | " .. cat)
            btn.info:SetText(freqDisplay)

            btn:Show()
        else
            btn:Hide()
        end
    end
    selectedIndex = 0
    frame:SetHeight(math.min(totalHeight + 10, 250))
    frame:Show()
end

function CommandSage_AutoComplete:OnEditBoxKeyDown(key)
    if not autoFrame or not autoFrame:IsShown() then
        return false
    end
    if key == "UP" then
        MoveSelection(-1)
        return true
    elseif key == "DOWN" then
        MoveSelection(1)
        return true
    elseif key == "ENTER" or key == "TAB" then
        local i = selectedIndex
        if i > 0 and content.buttons[i] and content.buttons[i]:IsShown() then
            self:AcceptSuggestion(content.buttons[i].suggestionData)
            return true
        end
    end
    return false
end

-- Snippet-based suggestions
local function GetSnippets(partial)
    if not CommandSage_Config.Get("preferences", "snippetEnabled") then
        return {}
    end
    local out = {}
    for _, snip in ipairs(snippetTemplates) do
        if snip.slash:find(partial:lower()) then
            table.insert(out, {
                slash = snip.snippet,
                data = { description = snip.desc },
                rank = 1
            })
        end
    end
    return out
end

-- Filter out commands if contextFiltering=on and we are in combat
local function FilterByContext(sugg)
    if not CommandSage_Config.Get("preferences", "contextFiltering") then
        return true
    end
    if InCombatLockdown() and (sugg.slash == "/macro") then
        return false
    end
    return true
end

function CommandSage_AutoComplete:GenerateSuggestions(typedText)
    local mode = CommandSage_Config.Get("preferences", "suggestionMode") or "fuzzy"
    local partialLower = typedText:lower()

    local possible = CommandSage_Trie:FindPrefix(partialLower)
    local matched = {}
    if mode == "fuzzy" then
        matched = CommandSage_FuzzyMatch:GetSuggestions(partialLower, possible)
    else
        -- strict mode
        for _, cmd in ipairs(possible) do
            table.insert(matched, { slash = cmd.slash, data = cmd.data, rank = 0 })
        end
        table.sort(matched, function(a, b)
            return a.slash < b.slash
        end)
    end
    -- add snippet suggestions
    local snippetList = GetSnippets(partialLower)
    for _, s in ipairs(snippetList) do
        table.insert(matched, s)
    end
    -- Filter out blacklisted or context
    local final = {}
    for _, m in ipairs(matched) do
        if not CommandSage_Analytics:IsBlacklisted(m.slash) and FilterByContext(m) then
            table.insert(final, m)
        end
    end
    return final
end

-- Real-time auto-complete hooking
local hookingFrame = CreateFrame("Frame")
hookingFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

hookingFrame:SetScript("OnEvent", function()
    local edit = ChatFrame1EditBox
    if not edit then
        return
    end

    -- Hook arrow keys & text changes
    edit:HookScript("OnKeyDown", function(self, key)
        if CommandSage_AutoComplete:OnEditBoxKeyDown(key) then
            -- swallow
        else
            self:SetPropagateKeyboardInput(true)
        end
    end)

    local orig = edit:GetScript("OnTextChanged")
    edit:SetScript("OnTextChanged", function(eBox, userInput)
        if orig then
            orig(eBox, userInput)
        end
        if not userInput then
            return
        end
        if CommandSage_Fallback:IsFallbackActive() then
            return
        end

        local text = eBox:GetText()
        if text == "" or text:sub(1, 1) ~= "/" then
            if autoFrame then
                autoFrame:Hide()
            end
            return
        end
        -- show suggestions after at least "/x" (2 chars)
        if #text < 2 then
            if autoFrame then
                autoFrame:Hide()
            end
            return
        end

        -- if user typed a recognized command + space => show parameter hints
        local firstWord = text:match("^(%S+)")
        local rest = text:match("^%S+%s+(.*)") or ""
        local paramHints = CommandSage_ParameterHelper:GetParameterSuggestions(firstWord, rest)
        if #paramHints > 0 then
            local paramSugg = {}
            for _, ph in ipairs(paramHints) do
                local s = firstWord .. " " .. ph
                table.insert(paramSugg, { slash = s, data = { description = "[Arg completion]" }, rank = 0 })
            end
            CommandSage_AutoComplete:ShowSuggestions(paramSugg)
            return
        end

        -- normal generation
        local final = CommandSage_AutoComplete:GenerateSuggestions(text)
        CommandSage_AutoComplete:ShowSuggestions(final)
    end)
end)
