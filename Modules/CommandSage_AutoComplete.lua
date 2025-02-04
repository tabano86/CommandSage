-- =============================================================================
-- CommandSage_AutoComplete.lua
-- Displays real-time suggestions in a pop-up frame under the edit box
-- =============================================================================

CommandSage_AutoComplete = {}

local autoCompleteFrame = nil
local suggestionButtons = {}
local MAX_SUGGESTIONS = 8

-- Creates or reuses the suggestions frame
local function CreateAutoCompleteFrame()
    if autoCompleteFrame then
        return autoCompleteFrame
    end

    autoCompleteFrame = CreateFrame("Frame", "CommandSage_AutoCompleteFrame", UIParent, "BackdropTemplate")
    autoCompleteFrame:SetSize(300, 150)
    autoCompleteFrame:SetPoint("TOPLEFT", ChatFrame1EditBox, "BOTTOMLEFT", 0, -2)
    autoCompleteFrame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 14,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    autoCompleteFrame:SetBackdropColor(0, 0, 0, 0.8)
    autoCompleteFrame:Hide()

    autoCompleteFrame.buttons = {}
    for i=1, MAX_SUGGESTIONS do
        local btn = CreateFrame("Button", nil, autoCompleteFrame)
        btn:SetHeight(16)
        btn:SetPoint("TOPLEFT", autoCompleteFrame, "TOPLEFT", 5, -5 - (i-1)*16)
        btn:SetPoint("RIGHT", autoCompleteFrame, "RIGHT", -5, 0)

        btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        btn.text:SetPoint("LEFT", btn, "LEFT", 0, 0)
        btn.text:SetJustifyH("LEFT")
        btn.text:SetTextColor(1,1,1,1)

        btn:SetScript("OnClick", function(self)
            local slashCmd = self.slashCmd
            if slashCmd then
                -- Insert or auto-type
                if CommandSage_Config.Get("preferences","animateAutoType") then
                    CommandSage_AutoType:BeginAutoType(slashCmd)
                else
                    ChatFrame1EditBox:SetText(slashCmd)
                    ChatFrame1EditBox:SetCursorPosition(#slashCmd)
                end
            end
            autoCompleteFrame:Hide()
        end)

        btn:Hide()
        autoCompleteFrame.buttons[i] = btn
    end

    return autoCompleteFrame
end

-- Updates the suggestions shown in the frame
local function ShowSuggestions(matches)
    local frame = CreateAutoCompleteFrame()
    for i,btn in ipairs(frame.buttons) do
        local data = matches[i]
        if data then
            btn.slashCmd = data.slash
            btn.text:SetText(data.slash)
            btn:Show()
        else
            btn.slashCmd = nil
            btn.text:SetText("")
            btn:Hide()
        end
    end

    if #matches == 0 then
        frame:Hide()
    else
        local totalHeight = 5 + (#matches * 16) + 5
        frame:SetHeight(totalHeight)
        frame:Show()
    end
end

-- The main function that handles partial input from the chat box
function CommandSage_AutoComplete:OnTextChanged(editBox, userInput)
    if not userInput then return end
    if CommandSage_Fallback:IsFallbackActive() then return end

    local text = editBox:GetText()
    if text == "" or text:sub(1,1) ~= "/" then
        -- Hide suggestions if user isn't typing a slash command
        if autoCompleteFrame then
            autoCompleteFrame:Hide()
        end
        return
    end

    -- Let's find matches
    local partialLower = text:lower()
    local possible = CommandSage_Trie:FindPrefix(partialLower)
    local fuzzy = CommandSage_Config.Get("preferences","fuzzyMatchEnabled")

    local matched = {}
    if fuzzy then
        matched = CommandSage_FuzzyMatch:GetSuggestions(partialLower, possible)
    else
        -- If fuzzy is off, we treat 'possible' as exact prefix matches
        for _, cmdObj in ipairs(possible) do
            table.insert(matched, { slash=cmdObj.slash, data=cmdObj.data, rank=0 })
        end
        table.sort(matched, function(a,b) return a.slash < b.slash end)
    end

    -- Truncate to max suggestions
    local maxSuggestions = CommandSage_Config.Get("preferences","maxSuggestions") or 8
    while #matched > maxSuggestions do
        table.remove(matched)
    end

    ShowSuggestions(matched)
end

-- Hook the default chat edit box after everything is loaded
local hookFrame = CreateFrame("Frame")
hookFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

hookFrame:SetScript("OnEvent", function(self, event)
    local editBox = ChatFrame1EditBox
    if editBox then
        local orig = editBox:GetScript("OnTextChanged")
        editBox:SetScript("OnTextChanged", function(eBox, userInput)
            if orig then orig(eBox, userInput) end
            CommandSage_AutoComplete:OnTextChanged(eBox, userInput)
        end)
    end
end)
