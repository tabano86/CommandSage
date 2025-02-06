CommandSage_MultiModal = {}
function CommandSage_MultiModal:OnVoiceCommand(phrase)
    if not phrase or phrase:trim() == "" then
        print("No match for empty voice input.")
        return
    end
    local possible = CommandSage_Trie:FindPrefix("/")
    local suggestions = CommandSage_FuzzyMatch:GetSuggestions(phrase:lower(), possible)
    if #suggestions == 0 then
        possible = CommandSage_Trie:AllCommands()
        suggestions = CommandSage_FuzzyMatch:GetSuggestions(phrase:lower(), possible)
    end
    if #suggestions > 0 then
        local top = suggestions[1]
        print("Voice recognized => " .. top.slash) -- no comma
    else
        print("No match for voice input: " .. phrase)
    end
end
function CommandSage_MultiModal:SimulateVoiceCommand(phrase)
    print("Simulating voice input: " .. phrase)
    self:OnVoiceCommand(phrase)
end
