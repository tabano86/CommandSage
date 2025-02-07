-- File: Modules/CommandSage_MultiModal.lua
-- Refactored multi-modal (voice) module

local MultiModal = {}

function MultiModal:OnVoiceCommand(phrase)
    if type(phrase) ~= "string" or phrase:match("^%s*$") then
        _G.print("No match for empty voice input.")
        return
    end

    local input = phrase:lower()
    if input:sub(1, 1) ~= "/" then
        input = "/" .. input
    end
    local possible = CommandSage_Trie and CommandSage_Trie:AllCommands() or {}
    local suggestions = CommandSage_FuzzyMatch and CommandSage_FuzzyMatch:GetSuggestions(input, possible) or {}

    if #suggestions > 0 then
        local top = suggestions[1]
        if top and type(top.slash) == "string" then
            _G.print("Voice recognized => " .. top.slash)
        else
            _G.print("No match for voice input: " .. phrase)
        end
    else
        local best, dist = CommandSage_FuzzyMatch and CommandSage_FuzzyMatch:SuggestCorrections(input) or { nil, nil }
        if type(best) == "string" then
            _G.print("Voice recognized => " .. best)
        else
            _G.print("No match for voice input: " .. phrase)
        end
    end
end

function MultiModal:SimulateVoiceCommand(phrase)
    _G.print("Simulating voice input: " .. phrase)
    self:OnVoiceCommand(phrase)
end

return MultiModal
