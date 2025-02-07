-- File: Modules/CommandSage_MultiModal.lua
-- Refactored multi-modal (voice) command handling
local MultiModal = {}

function MultiModal:OnVoiceCommand(phrase)
    if type(phrase) ~= "string" or phrase:match("^%s*$") then
        print("No match for empty voice input.")
        return
    end

    local input = phrase:lower()
    -- Retrieve all commands from the trie (voice input uses all commands)
    local possible = CommandSage_Trie:AllCommands() or {}
    local suggestions = CommandSage_FuzzyMatch:GetSuggestions(input, possible)

    if #suggestions > 0 then
        local top = suggestions[1]
        print("Voice recognized => " .. top.slash)
    else
        local best, dist = CommandSage_FuzzyMatch:SuggestCorrections(input)
        if best then
            print("Voice recognized => " .. best)
        else
            print("No match for voice input: " .. phrase)
        end
    end
end

function MultiModal:SimulateVoiceCommand(phrase)
    print("Simulating voice input: " .. phrase)
    self:OnVoiceCommand(phrase)
end

return MultiModal
