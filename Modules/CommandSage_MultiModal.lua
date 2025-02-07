-- File: Modules/CommandSage_MultiModal.lua
CommandSage_MultiModal = {}
function CommandSage_MultiModal:OnVoiceCommand(phrase)
    if not phrase or phrase:match("^%s*$") then
        print("No match for empty voice input.")
        return
    end
    local possible = CommandSage_Trie:AllCommands()  -- use all commands instead of FindPrefix("/")
    local suggestions = CommandSage_FuzzyMatch:GetSuggestions(phrase:lower(), possible)
    if #suggestions > 0 then
        local top = suggestions[1]
        print("Voice recognized => " .. top.slash)
    else
        local best, dist = CommandSage_FuzzyMatch:SuggestCorrections(phrase:lower())
        if best then
            print("Voice recognized => " .. best)
        else
            print("No match for voice input: " .. phrase)
        end
    end
end

function CommandSage_MultiModal:SimulateVoiceCommand(phrase)
    print("Simulating voice input: " .. phrase)
    self:OnVoiceCommand(phrase)
end

return CommandSage_MultiModal
