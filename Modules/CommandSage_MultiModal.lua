-- =============================================================================
-- CommandSage_MultiModal.lua
-- Example stub for voice or external input
-- =============================================================================

CommandSage_MultiModal = {}

function CommandSage_MultiModal:OnVoiceCommand(phrase)
    local possible = CommandSage_Trie:FindPrefix("/")
    local suggestions = CommandSage_FuzzyMatch:GetSuggestions(phrase:lower(), possible)
    if #suggestions > 0 then
        local top = suggestions[1]
        print("Voice recognized =>", top.slash)
    else
        print("No match for voice input:", phrase)
    end
end

function CommandSage_MultiModal:SimulateVoiceCommand(phrase)
    print("Simulating voice input:", phrase)
    self:OnVoiceCommand(phrase)
end
