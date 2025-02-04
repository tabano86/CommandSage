-- =============================================================================
-- CommandSage_MultiModal.lua
-- Multi-modal input (voice, macros, gestures) stubs
-- =============================================================================

CommandSage_MultiModal = {}

function CommandSage_MultiModal:OnVoiceCommand(transcribedText)
    -- The user said something that was transcribed
    -- We attempt to match it to a slash command
    local best = CommandSage_FuzzyMatch:GetSuggestions(transcribedText, CommandSage_Trie:FindPrefix("/"))
    if #best > 0 then
        local top = best[1]
        print("Voice recognized command: " .. top.slash)
        -- Possibly auto-execute or auto-complete
    else
        print("No match for voice input: " .. transcribedText)
    end
end
