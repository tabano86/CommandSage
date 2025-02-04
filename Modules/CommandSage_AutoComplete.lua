-- =============================================================================
-- CommandSage_AutoComplete.lua
-- Enhanced with:
--  - separate color for param suggestions
--  - multi-column row (slash, desc, usage)
--  - new "autocompleteOpenDirection" support (up or down)
--  - close window when exiting chat
--  - advanced key handling: Shift+Up/Down, Ctrl+C, etc.
--  - partial matching fallback if no prefix
--  - integrated shell context rewriting
-- =============================================================================

CommandSage_AutoComplete = {}

local autoFrame, scrollFrame, content
local selectedIndex = 0
local DEFAULT_MAX_SUGGEST = 20

-- Example snippet templates
local snippetTemplates = {
    { slash = "/macro", desc = "Create a new macro", snippet = "/macro new <macroName>" },
    { slash = "/dance", desc = "Fancy dance snippet", snippet = "/dance fancy" },
}

local function CreateAutoCompleteUI()
    if autoFrame then
        return autoFrame
    end

    local direction = CommandSage_Config.Get("preferences", "autocompleteOpenDirection") or "down"

    autoFrame = CreateFrame("Frame", "CommandSageAutoCompleteFrame", UIParent, "BackdropTemplate")

    if direction == "up" then
        autoFrame:SetPoint("BOTTOMLEFT", ChatFrame1EditBox, "TOPLEFT", 0, 2)
    else
        -- default "down"
        autoFrame:SetPoint("TOPLEFT", ChatFrame1EditBox, "BOTTOMLEFT", 0, -2)
    end
    autoFrame:SetSize(400, 250)

    if CommandSage_Config.Get("preferences", "advancedStyling") then
        autoFrame:SetBackdrop({
            bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile     = true, tileSize = 16, edgeSize = 16,
            insets   = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        autoFrame:SetBackdropColor(0, 0, 0, 0.85)
    else
        autoFrame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = nil,
            tile = false, tileSize = 0, edgeSize = 0,
        })
        autoFrame:SetBackdropColor(0.05, 0.05, 0.05, 0.9)
    end

    autoFrame:Hide()

    scrollFrame = CreateFrame("ScrollFrame", "CommandSageAutoScroll", autoFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 5, -5)
    scrollFrame:SetPoint("BOTTOMRIGHT", -28, 5)

    content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(1, 1)
    scrollFrame:SetScrollChild(content)
    content.buttons = {}

    local userMax = CommandSage_Config.Get("preferences", "maxSuggestionsOverride")
    local maxSuggest = userMax or DEFAULT_MAX_SUGGEST

    for i = 1, maxSuggest do
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

        -- Column: main slash text
        btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        btn.text:SetPoint("LEFT", 5, 0)
        btn.text:SetJustifyH("LEFT")
        btn.text:SetWidth(100)

        -- Column: description
        btn.desc = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        btn.desc:SetPoint("LEFT", btn.text, "RIGHT", 10, 0)
        btn.desc:SetJustifyH("LEFT")
        btn.desc:SetWidth(180)

        -- Column: usage/frequency
        btn.usage = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        btn.usage:SetPoint("LEFT", btn.desc, "RIGHT", 10, 0)
        btn.usage:SetJustifyH("LEFT")
        btn.usage:SetWidth(60)

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

local function MoveSelection(delta)
    if not content then return end

    local totalShown = 0
    for _, b in ipairs(content.buttons) do
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

    for i, b in ipairs(content.buttons) do
        if i == selectedIndex then
            b.bg:Show()
        else
            b.bg:Hide()
        end
    end
end

function CommandSage_AutoComplete:AcceptSuggestion(sugg)
    if not sugg then return end

    local slashCmd = sugg.slash
    if slashCmd then
        if CommandSage_Config.Get("preferences", "animateAutoType") then
            CommandSage_AutoType:BeginAutoType(slashCmd)
        else
            ChatFrame1EditBox:SetText(slashCmd)
            ChatFrame1EditBox:SetCursorPosition(#slashCmd)
        end
        CommandSage_AdaptiveLearning:IncrementUsage(slashCmd)
        CommandSage_HistoryPlayback:AddToHistory(slashCmd)
    end
    if autoFrame then
        autoFrame:Hide()
    end
end

function CommandSage_AutoComplete:ShowSuggestions(suggestions)
    local frame = CreateAutoCompleteUI()
    if #suggestions == 0 then
        frame:Hide()
        return
    end

    local userMax = CommandSage_Config.Get("preferences", "maxSuggestionsOverride")
    local maxSuggest = userMax or DEFAULT_MAX_SUGGEST
    local totalToShow = math.min(#suggestions, maxSuggest)
    local btnHeight = 20
    local totalHeight = totalToShow * btnHeight
    content:SetHeight(totalHeight)

    for i, btn in ipairs(content.buttons) do
        local s = suggestions[i]
        if i <= totalToShow and s then
            btn.suggestionData = s

            local usageScore = CommandSage_AdaptiveLearning:GetUsageScore(s.slash) or 0
            local freqDisplay = (usageScore > 0) and ("(" .. usageScore .. ")") or ""
            local cat = CommandSage_CommandOrganizer:GetCategory(s.slash)
            local desc = (s.data and s.data.description) or ""

            -- Param suggestion coloring:
            if s.isParamSuggestion and CommandSage_Config.Get("preferences", "showParamSuggestionsInColor") then
                btn.text:SetTextColor(unpack(CommandSage_Config.Get("preferences", "paramSuggestionsColor")))
            else
                btn.text:SetTextColor(1, 1, 1, 1)
            end

            -- Main slash text
            btn.text:SetText(s.slash)

            -- Optionally show description
            if CommandSage_Config.Get("preferences", "showDescriptionsInAutocomplete") then
                if desc == "" then
                    desc = cat
                end
                btn.desc:SetText(desc)
            else
                btn.desc:SetText("")
            end

            -- Usage/frequency display
            btn.usage:SetText(freqDisplay)

            btn:Show()
        else
            btn:Hide()
        end
    end

    selectedIndex = 0
    frame:SetHeight(math.min(totalHeight + 10, 250))
    frame:Show()
end

function CommandSage_AutoComplete:PassesContextFilter(sugg)
    if not CommandSage_Config.Get("preferences", "contextFiltering") then
        return true
    end
    if InCombatLockdown() and (sugg.slash == "/macro") then
        return false
    end
    return true
end

-- Generate all suggestions from typed text
function CommandSage_AutoComplete:GenerateSuggestions(typedText)
    local mode = CommandSage_Config.Get("preferences", "suggestionMode") or "fuzzy"

    -- If we have a shell context, rewrite typedText to slash form
    typedText = CommandSage_ShellContext:RewriteInputIfNeeded(typedText)

    local partialLower = typedText:lower()

    -- 1) Primary prefix search
    local possible = CommandSage_Trie:FindPrefix(partialLower)

    -- 2) If user wants partial fallback, check entire set if no prefix found
    if CommandSage_Config.Get("preferences", "partialFuzzyFallback") and #possible == 0 then
        -- get entire command list from the trie
        possible = CommandSage_Trie:AllCommands()
    end

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

    -- snippet suggestions
    if CommandSage_Config.Get("preferences", "snippetEnabled") then
        for _, snip in ipairs(snippetTemplates) do
            if snip.slash:find(partialLower, 1, true) then
                table.insert(matched, {
                    slash = snip.snippet,
                    data = { description = snip.desc },
                    rank = 1
                })
            end
        end
    end

    -- Filter out blacklisted or context
    local final = {}
    for _, m in ipairs(matched) do
        if not CommandSage_Analytics:IsBlacklisted(m.slash) and self:PassesContextFilter(m) then
            table.insert(final, m)
        end
    end

    if CommandSage_Config.Get("preferences", "favoritesSortingEnabled") then
        table.sort(final, function(a, b)
            local aFav = CommandSage_Analytics:IsFavorite(a.slash) and 1 or 0
            local bFav = CommandSage_Analytics:IsFavorite(b.slash) and 1 or 0
            if aFav ~= bFav then
                return aFav > bFav
            end
            return (a.rank or 0) > (b.rank or 0)
        end)
    else
        table.sort(final, function(a, b)
            return (a.rank or 0) > (b.rank or 0)
        end)
    end

    return final
end

local hookingFrame = CreateFrame("Frame")
hookingFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

local function CloseAutoCompleteOnChatDeactivate()
    if autoFrame and autoFrame:IsShown() then
        autoFrame:Hide()
    end
end

hookingFrame:SetScript("OnEvent", function()
    local edit = ChatFrame1EditBox
    if not edit then
        return
    end

    -- 1) Close auto-complete when exiting chat
    hooksecurefunc("ChatEdit_DeactivateChat", CloseAutoCompleteOnChatDeactivate)

    edit:HookScript("OnKeyDown", function(self, key)
        local text = self:GetText() or ""

        if not CommandSage_Config.Get("preferences", "advancedKeybinds") then
            -- fall back to original
            return
        end

        -- Terminal-like controls only if we are (A) typing slash or (B) in shell context
        local isSlash = (text:sub(1, 1) == "/")
        local isInShellContext = CommandSage_ShellContext:IsActive()
        if isSlash or isInShellContext then
            self:SetPropagateKeyboardInput(false)

            if key == "UP" then
                if IsShiftKeyDown() then
                    MoveSelection(-5)
                else
                    MoveSelection(-1)
                end
                return
            elseif key == "DOWN" then
                if IsShiftKeyDown() then
                    MoveSelection(5)
                else
                    MoveSelection(1)
                end
                return
            elseif key == "TAB" then
                if IsShiftKeyDown() then
                    -- SHIFT+Tab => reverse selection quickly
                    MoveSelection(-1)
                else
                    -- normal tab => accept current if selected or move next
                    if selectedIndex > 0 and content.buttons[selectedIndex]:IsShown() then
                        CommandSage_AutoComplete:AcceptSuggestion(content.buttons[selectedIndex].suggestionData)
                    else
                        MoveSelection(1)
                    end
                end
                return
            elseif key == "C" and IsControlKeyDown() then
                -- Ctrl+C => cancel input entirely
                self:SetText("")
                if autoFrame then autoFrame:Hide() end
                return
            end
        else
            -- if not a slash or shell context, let default chat happen
            self:SetPropagateKeyboardInput(true)
        end
    end)

    -- 3) Text changed => generate suggestions
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
        -- If user typed nothing, hide
        if text == "" then
            if autoFrame then
                autoFrame:Hide()
            end
            return
        end

        -- Check if we typed "command param..."
        local firstWord = text:match("^(%S+)")
        local rest = text:match("^%S+%s+(.*)") or ""
        local paramHints = CommandSage_ParameterHelper:GetParameterSuggestions(firstWord, rest)
        if #paramHints > 0 then
            local paramSugg = {}
            for _, ph in ipairs(paramHints) do
                table.insert(paramSugg, {
                    slash = firstWord .. " " .. ph,
                    data  = { description = "[Arg completion]" },
                    rank  = 0,
                    isParamSuggestion = true
                })
            end
            CommandSage_AutoComplete:ShowSuggestions(paramSugg)
            return
        end

        -- normal suggestions
        local final = CommandSage_AutoComplete:GenerateSuggestions(text)
        CommandSage_AutoComplete:ShowSuggestions(final)
    end)
end)
