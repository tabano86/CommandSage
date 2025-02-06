-- Modules/CommandSage_AutoComplete.lua
require("Modules.CommandSage_FuzzyMatch")
require("Modules.CommandSage_AutoType")

CommandSage_AutoComplete = {}
local autoFrame, scrollFrame, content
local selectedIndex = 0
local DEFAULT_MAX_SUGGEST = 20
local snippetTemplates = {
    { slash = "/macro", desc = "Create a macro", snippet = "/macro new <macroName>" },
    { slash = "/dance", desc = "Fancy dance", snippet = "/dance fancy" },
    { slash = "/thanks", desc = "Express gratitude", snippet = "/thanks" },
    { slash = "/sorry", desc = "Apologize", snippet = "/sorry" },
    { slash = "/hello", desc = "Say hello", snippet = "/hello" },
    { slash = "/cheer", desc = "Cheer", snippet = "/cheer" },
    { slash = "/wave", desc = "Wave", snippet = "/wave" },
    { slash = "/point", desc = "Point", snippet = "/point" },
    { slash = "/sit", desc = "Sit down", snippet = "/sit" },
    { slash = "/stand", desc = "Stand up", snippet = "/stand" },
    { slash = "/roar", desc = "Roar", snippet = "/roar" },
    { slash = "/laugh", desc = "Laugh", snippet = "/laugh" },
    { slash = "/cry", desc = "Cry", snippet = "/cry" },
    { slash = "/flirt", desc = "Flirt", snippet = "/flirt" },
    { slash = "/kiss", desc = "Blow a kiss", snippet = "/kiss" },
    { slash = "/bow", desc = "Bow", snippet = "/bow" },
    { slash = "/kneel", desc = "Kneel", snippet = "/kneel" },
    { slash = "/beg", desc = "Beg", snippet = "/beg" },
    { slash = "/yell", desc = "Yell", snippet = "/yell" },
    { slash = "/dance", desc = "Perform a dance", snippet = "/dance" },
    { slash = "/sleep", desc = "Sleep", snippet = "/sleep" },
    { slash = "/cower", desc = "Cower", snippet = "/cower" },
    { slash = "/shoo", desc = "Shoo", snippet = "/shoo" },
    { slash = "/thank", desc = "Thank someone", snippet = "/thank" },
    { slash = "/whistle", desc = "Whistle", snippet = "/whistle" },
    { slash = "/clap", desc = "Clap", snippet = "/clap" },
    { slash = "/no", desc = "Shake head no", snippet = "/no" },
    { slash = "/yes", desc = "Shake head yes", snippet = "/yes" },
    { slash = "/rude", desc = "Be rude", snippet = "/rude" },
    { slash = "/sad", desc = "Show sadness", snippet = "/sad" },
    { slash = "/angry", desc = "Show anger", snippet = "/angry" },
    { slash = "/facepalm", desc = "Facepalm", snippet = "/facepalm" },
    { slash = "/confused", desc = "Express confusion", snippet = "/confused" },
    { slash = "/laugh", desc = "Laugh loudly", snippet = "/laugh" },
    { slash = "/gasp", desc = "Gasp", snippet = "/gasp" },
    { slash = "/grin", desc = "Grin", snippet = "/grin" },
    { slash = "/wink", desc = "Wink", snippet = "/wink" },
    { slash = "/bow", desc = "Bow respectfully", snippet = "/bow" },
    { slash = "/hug", desc = "Hug someone", snippet = "/hug" },
    { slash = "/applaud", desc = "Applaud", snippet = "/applaud" }
}

function CommandSage_AutoComplete:MoveSelection(delta)
    if not content then return end
    local totalShown = 0
    for _, b in ipairs(content.buttons) do
        if b:IsShown() then
            totalShown = totalShown + 1
        end
    end
    if totalShown == 0 then return end

    selectedIndex = selectedIndex + delta
    if selectedIndex < 1 then
        selectedIndex = totalShown
    elseif selectedIndex > totalShown then
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

function CommandSage_AutoComplete:AcceptOrAdvance()
    if not content then return end
    if selectedIndex > 0 and content.buttons[selectedIndex]:IsShown() then
        self:AcceptSuggestion(content.buttons[selectedIndex].suggestionData)
    else
        self:MoveSelection(1)
    end
end

local function ApplyStylingToAutoFrame(frame)
    local prefs = CommandSage_Config.Get("preferences")
    local advancedStyling = prefs.advancedStyling
    local bgColor = prefs.autocompleteBgColor or { 0, 0, 0, 0.85 }
    local scale = prefs.uiScale or 1.0
    local highlightColor = prefs.autocompleteHighlightColor or { 0.6, 0.6, 0.6, 0.3 }

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
            tile = false, tileSize = 0, edgeSize = 0,
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
            local offset = math.abs(math.sin(self._rainbowOffset))
            frame.rainbowTex:SetAlpha(offset)
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

local function CreateAutoCompleteUI()
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
    ApplyStylingToAutoFrame(autoFrame)
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

        btn:SetScript("OnEnter", function(self) self.bg:Show() end)
        btn:SetScript("OnLeave", function(self) self.bg:Hide() end)
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
    if totalShown == 0 then return end

    selectedIndex = selectedIndex + delta
    if selectedIndex < 1 then
        selectedIndex = totalShown
    elseif selectedIndex > totalShown then
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
    ApplyStylingToAutoFrame(frame)

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

    local paramGlowEnabled = CommandSage_Config.Get("preferences", "paramGlowEnabled")
    for i, btn in ipairs(content.buttons) do
        local s = suggestions[i]
        if i <= totalToShow and s then
            btn.suggestionData = s

            local usageScore = CommandSage_AdaptiveLearning:GetUsageScore(s.slash)
            local freqDisplay = (usageScore > 0) and ("(" .. usageScore .. ")") or ""

            local cat = CommandSage_CommandOrganizer:GetCategory(s.slash)
            local desc = (s.data and s.data.description) or ""

            if s.isParamSuggestion and CommandSage_Config.Get("preferences", "showParamSuggestionsInColor") then
                btn.text:SetTextColor(unpack(CommandSage_Config.Get("preferences", "paramSuggestionsColor")))
                if paramGlowEnabled then
                    btn.highlight:SetColorTexture(1, 0, 0, 0.4)
                end
            else
                btn.text:SetTextColor(1, 1, 1, 1)
                btn.highlight:SetColorTexture(0.6, 0.6, 0.6, 0.3)
            end

            btn.text:SetText(s.slash)
            if CommandSage_Config.Get("preferences", "showDescriptionsInAutocomplete") then
                if desc == "" then
                    desc = cat
                end
                btn.desc:SetText(desc)
            else
                btn.desc:SetText("")
            end

            if usageScore and usageScore > 10 then
                btn.usage:SetTextColor(0, 1, 0, 1)
            else
                btn.usage:SetTextColor(1, 1, 1, 1)
            end
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

function CommandSage_AutoComplete:CloseSuggestions()
    if autoFrame then
        autoFrame:Hide()
    end
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

local function MergeHistoryWithCommands(typedLower, possible)
    local hist = CommandSage_HistoryPlayback:GetHistory()
    local merged = {}
    local existing = {}
    for _, cmdObj in ipairs(possible) do
        existing[cmdObj.slash] = true
    end

    -- copy possible first
    for _, cmdObj in ipairs(possible) do
        table.insert(merged, cmdObj)
    end

    -- if partial is found to produce 0 from the Trie, or partialFuzzyFallback is set,
    -- we want to add matching history commands even if they fail fuzzy
    local fallback = CommandSage_Config.Get("preferences", "partialFuzzyFallback")
    for _, hcmd in ipairs(hist) do
        local lower = hcmd:lower()
        local foundSimple = (lower:find(typedLower, 1, true) ~= nil)
        if foundSimple or fallback then
            if not existing[lower] then
                table.insert(merged, { slash = hcmd, data = { description = "History command" }, rank = 0 })
            end
        end
    end
    return merged
end

function CommandSage_AutoComplete:GenerateSuggestions(typedText)
    local mode = CommandSage_Config.Get("preferences", "suggestionMode") or "fuzzy"
    typedText = CommandSage_ShellContext:RewriteInputIfNeeded(typedText)
    local partialLower = typedText:lower()

    if partialLower:sub(1, 1) ~= "/" and not CommandSage_ShellContext:IsActive() then
        partialLower = "/" .. partialLower
    end

    local possible = CommandSage_Trie:FindPrefix(partialLower)
    local fallback = CommandSage_Config.Get("preferences", "partialFuzzyFallback")

    if fallback and #possible == 0 then
        -- skip fuzzy, show everything
        possible = CommandSage_Trie:AllCommands()
        -- also merge history ignoring fuzzy
        possible = MergeHistoryWithCommands(partialLower, possible)
        -- skip fuzzy entirely
        local final = {}
        for _, cmd in ipairs(possible) do
            if not CommandSage_Analytics:IsBlacklisted(cmd.slash) and self:PassesContextFilter(cmd) then
                table.insert(final, { slash = cmd.slash, data = cmd.data, rank = 0, isParamSuggestion = cmd.isParamSuggestion })
            end
        end
        -- snippet expansions
        if CommandSage_Config.Get("preferences", "snippetEnabled") then
            for _, snip in ipairs(snippetTemplates) do
                if snip.slash:find(partialLower, 1, true) then
                    table.insert(final, {
                        slash = snip.snippet,
                        data = { description = snip.desc },
                        rank = -1
                    })
                end
            end
        end
        -- favorites sorting, snippet last
        if CommandSage_Config.Get("preferences", "favoritesSortingEnabled") then
            table.sort(final, function(a, b)
                local aFav = CommandSage_Analytics:IsFavorite(a.slash) and 1 or 0
                local bFav = CommandSage_Analytics:IsFavorite(b.slash) and 1 or 0
                if aFav ~= bFav then
                    return aFav > bFav
                end
                -- snippet last
                local aSnip = (a.rank == -1)
                local bSnip = (b.rank == -1)
                if aSnip ~= bSnip then
                    return not aSnip
                end
                return (a.rank or 0) > (b.rank or 0)
            end)
        else
            table.sort(final, function(a, b)
                local aSnip = (a.rank == -1)
                local bSnip = (b.rank == -1)
                if aSnip ~= bSnip then
                    return not aSnip
                end
                return (a.rank or 0) > (b.rank or 0)
            end)
        end
        return final
    end

    -- Normal path
    possible = MergeHistoryWithCommands(partialLower, possible)
    local matched = {}

    if mode == "fuzzy" then
        local rawMatches = CommandSage_FuzzyMatch:GetSuggestions(partialLower, possible)
        -- need snippet expansions after fuzzy
        for _, m in ipairs(rawMatches) do
            if not CommandSage_Analytics:IsBlacklisted(m.slash) and self:PassesContextFilter(m) then
                table.insert(matched, m)
            end
        end
    else
        -- strict prefix sort
        for _, cmd in ipairs(possible) do
            if not CommandSage_Analytics:IsBlacklisted(cmd.slash) and self:PassesContextFilter(cmd) then
                table.insert(matched, { slash = cmd.slash, data = cmd.data, rank = 0 })
            end
        end
        table.sort(matched, function(a, b)
            return a.slash < b.slash
        end)
    end

    -- snippet expansions
    if CommandSage_Config.Get("preferences", "snippetEnabled") then
        for _, snip in ipairs(snippetTemplates) do
            if snip.slash:find(partialLower, 1, true) then
                table.insert(matched, {
                    slash = snip.snippet,
                    data = { description = snip.desc },
                    rank = -1
                })
            end
        end
    end

    -- final sort with favorites + snippet-later
    if CommandSage_Config.Get("preferences", "favoritesSortingEnabled") then
        table.sort(matched, function(a, b)
            local aFav = CommandSage_Analytics:IsFavorite(a.slash) and 1 or 0
            local bFav = CommandSage_Analytics:IsFavorite(b.slash) and 1 or 0
            if aFav ~= bFav then
                return aFav > bFav
            end
            local aSnip = (a.rank == -1)
            local bSnip = (b.rank == -1)
            if aSnip ~= bSnip then
                return not aSnip
            end
            return (a.rank or 0) > (b.rank or 0)
        end)
    else
        table.sort(matched, function(a, b)
            local aSnip = (a.rank == -1)
            local bSnip = (b.rank == -1)
            if aSnip ~= bSnip then
                return not aSnip
            end
            return (a.rank or 0) > (b.rank or 0)
        end)
    end

    return matched
end

-- hooking code below unchanged...
local hookingFrame = CreateFrame("Frame")
hookingFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

local function CloseAutoCompleteOnChatDeactivate()
    if autoFrame and autoFrame:IsShown() then
        autoFrame:Hide()
    end
end

hookingFrame:SetScript("OnEvent", function()
    local edit = ChatFrame1EditBox
    if not edit then return end

    hooksecurefunc("ChatEdit_DeactivateChat", CloseAutoCompleteOnChatDeactivate)

    edit:HookScript("OnKeyDown", function(self, key)
        local text = self:GetText() or ""
        local isSlash = (text:sub(1, 1) == "/")
        local isInShellContext = CommandSage_ShellContext:IsActive()
        if not CommandSage_Config.Get("preferences", "advancedKeybinds") then
            self:SetPropagateKeyboardInput(true)
            return
        end
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
                    MoveSelection(-1)
                else
                    if selectedIndex > 0 and content.buttons[selectedIndex]:IsShown() then
                        CommandSage_AutoComplete:AcceptSuggestion(content.buttons[selectedIndex].suggestionData)
                    else
                        MoveSelection(1)
                    end
                end
                return
            elseif key == "C" and IsControlKeyDown() then
                self:SetText("")
                if autoFrame then
                    autoFrame:Hide()
                end
                return
            end
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
        if text == "" then
            if autoFrame then
                autoFrame:Hide()
            end
            return
        end
        local firstChar = text:sub(1, 1)
        if firstChar ~= "/" and not CommandSage_ShellContext:IsActive() then
            if autoFrame then
                autoFrame:Hide()
            end
            return
        end
        local firstWord = text:match("^(%S+)")
        local rest = text:match("^%S+%s+(.*)") or ""
        local paramHints = CommandSage_ParameterHelper:GetParameterSuggestions(firstWord, rest)
        if #paramHints > 0 then
            local paramSugg = {}
            for _, ph in ipairs(paramHints) do
                table.insert(paramSugg, {
                    slash = firstWord .. " " .. ph,
                    data = { description = "[Arg completion]" },
                    rank = 0,
                    isParamSuggestion = true
                })
            end
            CommandSage_AutoComplete:ShowSuggestions(paramSugg)
            return
        end
        local final = CommandSage_AutoComplete:GenerateSuggestions(text)
        CommandSage_AutoComplete:ShowSuggestions(final)
    end)
end)

function CommandSage_AutoComplete:CloseSuggestions()
    if autoFrame then
        autoFrame:Hide()
    end
end
