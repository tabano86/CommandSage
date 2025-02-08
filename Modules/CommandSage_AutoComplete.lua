-- File: Modules/CommandSage_AutoComplete.lua
-- Refactored robust auto‐complete module with iTerm2/zsh-like tab behavior.

CommandSage_AutoComplete = {}
local autoFrame, scrollFrame, content
local selectedIndex = 0
local DEFAULT_MAX_SUGGEST = 20

-- Keep a reference to the current suggestion list and the user’s typed text
CommandSage_AutoComplete.suggestions = {}
CommandSage_AutoComplete.lastTyped = ""

--------------------------------------------------------------------------------
-- Utility: Find the longest common prefix among a set of strings.
--------------------------------------------------------------------------------
local function longestCommonPrefix(str1, str2)
    local len = math.min(#str1, #str2)
    local idx = 1
    while idx <= len and str1:sub(idx, idx) == str2:sub(idx, idx) do
        idx = idx + 1
    end
    return str1:sub(1, idx - 1)
end

local function getCommonPrefix(suggestionsList, typedText)
    if #suggestionsList == 0 then
        return typedText or ""
    end
    local prefix = suggestionsList[1].slash or ""
    for i = 2, #suggestionsList do
        prefix = longestCommonPrefix(prefix, suggestionsList[i].slash or "")
        if prefix == "" then
            break
        end
    end
    -- If the typedText is already longer than prefix, keep typedText.
    if #typedText > #prefix then
        return typedText
    end
    return prefix
end

--------------------------------------------------------------------------------
-- IsVisible: Returns true if the auto-complete frame is shown.
--------------------------------------------------------------------------------
function CommandSage_AutoComplete:IsVisible()
    return autoFrame and autoFrame:IsShown()
end

--------------------------------------------------------------------------------
-- MoveSelection: Cycle through the visible suggestion buttons.
--------------------------------------------------------------------------------
function CommandSage_AutoComplete:MoveSelection(delta)
    if not content or not content.buttons then
        return
    end
    local totalShown = 0
    for _, btn in ipairs(content.buttons) do
        if btn:IsShown() then
            totalShown = totalShown + 1
        end
    end
    if totalShown == 0 then
        return
    end

    selectedIndex = selectedIndex + delta
    if selectedIndex < 1 then
        selectedIndex = totalShown
    elseif selectedIndex > totalShown then
        selectedIndex = 1
    end

    for i, btn in ipairs(content.buttons) do
        if i == selectedIndex then
            btn.bg:Show()
        else
            btn.bg:Hide()
        end
    end
end

--------------------------------------------------------------------------------
-- AcceptSuggestion: Accept a suggestion and update history/usage.
--------------------------------------------------------------------------------
function CommandSage_AutoComplete:AcceptSuggestion(sugg)
    if not sugg or type(sugg.slash) ~= "string" then
        return
    end
    local slashCmd = sugg.slash
    local animate = CommandSage_Config.Get("preferences", "animateAutoType")
    local editBox = _G.ChatFrame1EditBox

    if animate and CommandSage_AutoType and type(CommandSage_AutoType.BeginAutoType) == "function" then
        CommandSage_AutoType:BeginAutoType(slashCmd)
    else
        -- Fallback: set text immediately.
        editBox:SetText(slashCmd)
        editBox:SetCursorPosition(#slashCmd)
    end

    CommandSage_AdaptiveLearning:IncrementUsage(slashCmd)
    CommandSage_HistoryPlayback:AddToHistory(slashCmd)
    if autoFrame then
        autoFrame:Hide()
    end
end

--------------------------------------------------------------------------------
-- OnTabPress: Called when TAB is pressed (shiftDown indicates shift+tab).
-- Tries to do partial expansion or accept/cycle suggestions, iTerm2/zsh-like.
--------------------------------------------------------------------------------
function CommandSage_AutoComplete:OnTabPress(shiftDown)
    if not self.suggestions or #self.suggestions == 0 then
        return
    end

    if #self.suggestions == 1 then
        -- Single suggestion => accept immediately.
        self:AcceptSuggestion(self.suggestions[1])
        return
    end

    -- Multiple suggestions => attempt partial prefix expansion:
    local expanded = getCommonPrefix(self.suggestions, self.lastTyped or "")
    local editBox = _G.ChatFrame1EditBox
    if not editBox then
        return
    end

    if expanded and expanded ~= "" and #expanded > #self.lastTyped then
        -- We can expand the typed text further without fully disambiguating
        editBox:SetText(expanded)
        editBox:SetCursorPosition(#expanded)
        self.lastTyped = expanded
        -- Rebuild suggestions for the newly expanded text:
        local final = self:GenerateSuggestions(expanded)
        self:ShowSuggestions(final, expanded)
    else
        -- If we cannot expand further, cycle selection:
        if shiftDown then
            self:MoveSelection(-1)
        else
            self:MoveSelection(1)
        end
    end
end

--------------------------------------------------------------------------------
-- GenerateSuggestions: Return sorted suggestions for a given input.
--------------------------------------------------------------------------------
function CommandSage_AutoComplete:GenerateSuggestions(typedText)
    if type(typedText) ~= "string" then
        typedText = tostring(typedText or "")
    end
    local mode = CommandSage_Config.Get("preferences", "suggestionMode") or "fuzzy"
    typedText = CommandSage_ShellContext:RewriteInputIfNeeded(typedText)
    local partialLower = typedText:lower()
    if partialLower:sub(1, 1) ~= "/" and not CommandSage_ShellContext:IsActive() then
        partialLower = "/" .. partialLower
    end

    if #partialLower <= 1 then
        local allCommands = CommandSage_Trie:AllCommands() or {}
        allCommands = self:MergeHistoryWithCommands(partialLower, allCommands)
        local final = {}
        for _, cmd in ipairs(allCommands) do
            if not CommandSage_Analytics:IsBlacklisted(cmd.slash) and self:PassesContextFilter(cmd) then
                table.insert(final, {
                    slash = cmd.slash,
                    data = cmd.data,
                    rank = 0,
                    isSnippet = false,
                    isParamSuggestion = cmd.isParamSuggestion
                })
            end
        end
        self:MaybeAddSnippets(partialLower, final)
        self:SortSuggestions(final)
        return final
    end

    local possible = CommandSage_Trie:FindPrefix(partialLower) or {}
    if #possible == 0 and CommandSage_Config.Get("preferences", "partialFuzzyFallback") then
        possible = CommandSage_Trie:AllCommands() or {}
    end
    possible = self:MergeHistoryWithCommands(partialLower, possible)

    local matched = {}
    if mode == "fuzzy" then
        local rawMatches = CommandSage_FuzzyMatch:GetSuggestions(partialLower, possible) or {}
        for _, m in ipairs(rawMatches) do
            if not CommandSage_Analytics:IsBlacklisted(m.slash) and self:PassesContextFilter(m) then
                m.isSnippet = false
                table.insert(matched, m)
            end
        end
    else
        -- strict mode
        for _, cmd in ipairs(possible) do
            if not CommandSage_Analytics:IsBlacklisted(cmd.slash) and self:PassesContextFilter(cmd) then
                table.insert(matched, { slash = cmd.slash, data = cmd.data, rank = 0, isSnippet = false })
            end
        end
        table.sort(matched, function(a, b)
            return a.slash < b.slash
        end)
    end

    if #matched == 0 and CommandSage_Config.Get("preferences", "partialFuzzyFallback") then
        matched = {}
        for _, cmd in ipairs(possible) do
            if not CommandSage_Analytics:IsBlacklisted(cmd.slash) and self:PassesContextFilter(cmd) then
                table.insert(matched, { slash = cmd.slash, data = cmd.data, rank = 0, isSnippet = false })
            end
        end
    end

    self:MaybeAddSnippets(partialLower, matched)
    self:SortSuggestions(matched)
    return matched
end

--------------------------------------------------------------------------------
-- MergeHistoryWithCommands: merges typed-lower or fallback with user's history.
--------------------------------------------------------------------------------
function CommandSage_AutoComplete:MergeHistoryWithCommands(typedLower, possible)
    local hist = CommandSage_HistoryPlayback:GetHistory() or {}
    local merged = {}
    local existing = {}
    for _, cmdObj in ipairs(possible) do
        local key = cmdObj.slash:lower()
        existing[key] = true
        table.insert(merged, cmdObj)
    end
    local fallback = CommandSage_Config.Get("preferences", "partialFuzzyFallback")
    for _, hcmd in ipairs(hist) do
        local lower = hcmd:lower()
        local foundSimple = lower:find(typedLower, 1, true) ~= nil
        if foundSimple or fallback then
            if not existing[lower] then
                table.insert(merged, {
                    slash = hcmd,
                    data = { description = "History command" },
                    rank = 0,
                    isParamSuggestion = false
                })
            end
        end
    end
    return merged
end

--------------------------------------------------------------------------------
-- MaybeAddSnippets: If snippetEnabled, check for snippet matches.
--------------------------------------------------------------------------------
function CommandSage_AutoComplete:MaybeAddSnippets(partialLower, suggestionsList)
    if not CommandSage_Config.Get("preferences", "snippetEnabled") then
        return
    end
    -- Very simple snippet templates:
    local snippetTemplates = {
        { slash = "/macro", desc = "Create a macro", snippet = "/macro new <macroName>" },
        { slash = "/dance", desc = "Fancy dance", snippet = "/dance fancy" },
        { slash = "/hello", desc = "Say hello", snippet = "/hello" },
        -- ... truncated for brevity; you can re-add your custom snippet data ...
    }
    for _, snip in ipairs(snippetTemplates) do
        if snip.slash and snip.slash:find(partialLower, 1, true) then
            table.insert(suggestionsList, {
                slash = snip.snippet,
                data = { description = snip.desc },
                rank = -1,
                isSnippet = true,
                isParamSuggestion = false,
            })
        end
    end
end

--------------------------------------------------------------------------------
-- SortSuggestions: Sort logic, including snippet and favorites sorting.
--------------------------------------------------------------------------------
function CommandSage_AutoComplete:SortSuggestions(suggestions)
    local function sortFunc(a, b)
        if a.isSnippet ~= b.isSnippet then
            return not a.isSnippet
        end
        local aFav = CommandSage_Analytics:IsFavorite(a.slash) and 1 or 0
        local bFav = CommandSage_Analytics:IsFavorite(b.slash) and 1 or 0
        if CommandSage_Config.Get("preferences", "favoritesSortingEnabled") then
            if aFav ~= bFav then
                return aFav > bFav
            end
        end
        return (a.rank or 0) > (b.rank or 0)
    end
    table.sort(suggestions, sortFunc)
end

--------------------------------------------------------------------------------
-- PassesContextFilter: Minimal example that always returns true in this snippet.
--------------------------------------------------------------------------------
function CommandSage_AutoComplete:PassesContextFilter(cmdObj)
    return true
end

--------------------------------------------------------------------------------
-- ShowSuggestions: Renders the suggestion list in a scrollable frame.
-- second argument typedText is stored in self.lastTyped for expansions.
--------------------------------------------------------------------------------
function CommandSage_AutoComplete:ShowSuggestions(suggestions, typedText)
    if not suggestions or #suggestions == 0 then
        if autoFrame then autoFrame:Hide() end
        return
    end

    -- Track these for partial expansions (OnTabPress).
    self.suggestions = suggestions
    self.lastTyped = typedText or ""

    local frame = self:CreateAutoCompleteUI()
    frame:Show()

    -- Force default selection to first suggestion.
    selectedIndex = 1

    for i, btn in ipairs(content.buttons) do
        local s = suggestions[i]
        if s then
            btn.suggestionData = s
            btn.text:SetText(s.slash or "")
            local desc = (s.data and s.data.description) or ""
            btn.desc:SetText(desc)
            local usage = CommandSage_AdaptiveLearning:GetUsageScore(s.slash)
            btn.usage:SetText(tostring(usage or 0))
            if i == selectedIndex then
                btn.bg:Show()
            else
                btn.bg:Hide()
            end
            btn:Show()
        else
            btn:Hide()
        end
    end
    content:SetSize(400, #suggestions * 20)
    scrollFrame:SetVerticalScroll(0)
end

--------------------------------------------------------------------------------
-- CloseSuggestions: Hides the autocomplete frame.
--------------------------------------------------------------------------------
function CommandSage_AutoComplete:CloseSuggestions()
    if autoFrame then
        autoFrame:Hide()
    end
end

--------------------------------------------------------------------------------
-- CreateAutoCompleteUI: Build (or return) the auto-complete frame.
--------------------------------------------------------------------------------
function CommandSage_AutoComplete:CreateAutoCompleteUI()
    if autoFrame then
        return autoFrame
    end

    autoFrame = CreateFrame("Frame", "CommandSageAutoCompleteFrame", UIParent, "BackdropTemplate")
    local direction = CommandSage_Config.Get("preferences", "autocompleteOpenDirection") or "down"
    if direction == "up" then
        autoFrame:SetPoint("BOTTOMLEFT", ChatFrame1EditBox, "TOPLEFT", 0, 2)
    else
        autoFrame:SetPoint("TOPLEFT", ChatFrame1EditBox, "BOTTOMLEFT", 0, -2)
    end
    autoFrame:SetSize(400, 250)
    self:ApplyStylingToAutoFrame(autoFrame)
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

        btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        btn.text:SetPoint("LEFT", 5, 0)
        btn.text:SetJustifyH("LEFT")
        btn.text:SetWidth(100)

        btn.desc = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        btn.desc:SetPoint("LEFT", btn.text, "RIGHT", 10, 0)
        btn.desc:SetJustifyH("LEFT")
        btn.desc:SetWidth(180)

        btn.usage = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        btn.usage:SetPoint("LEFT", btn.desc, "RIGHT", 10, 0)
        btn.usage:SetJustifyH("LEFT")
        btn.usage:SetWidth(60)

        btn:SetScript("OnEnter", function(self)
            self.bg:Show()
        end)
        btn:SetScript("OnLeave", function(self)
            if i ~= selectedIndex then
                self.bg:Hide()
            end
        end)
        btn:SetScript("OnClick", function(self)
            CommandSage_AutoComplete:AcceptSuggestion(self.suggestionData)
        end)
        btn:Hide()

        content.buttons[i] = btn
    end

    return autoFrame
end

--------------------------------------------------------------------------------
-- ApplyStylingToAutoFrame: Apply some styling to the auto-frame based on prefs.
--------------------------------------------------------------------------------
function CommandSage_AutoComplete:ApplyStylingToAutoFrame(frame)
    local prefs = CommandSage_Config.Get("preferences") or {}
    local advancedStyling = prefs.advancedStyling
    local bgColor = prefs.autocompleteBgColor or { 0, 0, 0, 0.85 }
    local scale = prefs.uiScale or 1.0

    frame:SetScale(scale)
    if advancedStyling then
        frame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
    else
        frame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = nil,
            tile = false,
        })
    end
    frame:SetBackdropColor(unpack(bgColor))

    if prefs.rainbowBorderEnabled then
        frame.rainbowTex = frame.rainbowTex or frame:CreateTexture(nil, "OVERLAY")
        frame.rainbowTex:SetAllPoints()
        frame.rainbowTex:SetTexture("Interface\\AddOns\\CommandSage\\Media\\RainbowBorder")
        frame.rainbowTex:SetBlendMode("ADD")
        frame:SetScript("OnUpdate", function(self, elapsed)
            self._rainbowOffset = (self._rainbowOffset or 0) + elapsed * 0.5
            local alpha = math.abs(math.sin(self._rainbowOffset))
            frame.rainbowTex:SetAlpha(alpha)
        end)
    else
        if frame.rainbowTex then
            frame.rainbowTex:Hide()
        end
        frame:SetScript("OnUpdate", nil)
    end

    if prefs.spinningIconEnabled then
        frame.spinIcon = frame.spinIcon or frame:CreateTexture(nil, "ARTWORK")
        frame.spinIcon:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
        frame.spinIcon:SetTexture("Interface\\AddOns\\CommandSage\\Media\\SpinIcon")
        frame.spinIcon:SetSize(24, 24)
        frame.spinIcon:Show()
        frame._spinTime = 0
        frame:HookScript("OnUpdate", function(self, elapsed)
            self._spinTime = (self._spinTime or 0) + elapsed
            frame.spinIcon:SetRotation(self._spinTime)
        end)
    else
        if frame.spinIcon then
            frame.spinIcon:Hide()
        end
    end
end

--------------------------------------------------------------------------------
-- Return the module
--------------------------------------------------------------------------------
return CommandSage_AutoComplete
