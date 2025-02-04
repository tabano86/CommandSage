-- =============================================================================
-- CommandSage_ParameterHelper.lua
-- Show subcommands, expected args inline (colored differently if desired)
-- Now includes /w param suggestions for recent players or friend list
-- =============================================================================

CommandSage_ParameterHelper = {}

local knownParams = {
    ["/dance"] = { "silly", "fancy", "epic" },
    ["/macro"] = { "new", "delete", "edit" },
}

-- Example caching of recent whisper targets or friends
local recentWhispers = {}
local friendNames = {}

-- Call this periodically or on relevant events to update friendNames
local function UpdateFriendList()
    wipe(friendNames)
    local numFriends = C_FriendList.GetNumFriends() or 0
    for i = 1, numFriends do
        local friendInfo = C_FriendList.GetFriendInfoByIndex(i)
        if friendInfo and friendInfo.name then
            table.insert(friendNames, friendInfo.name)
        end
    end
end

-- Called from somewhere else whenever a whisper is sent
function CommandSage_ParameterHelper:RecordWhisperTarget(targetName)
    if targetName and targetName ~= "" then
        recentWhispers[targetName:lower()] = true
    end
end

function CommandSage_ParameterHelper:GetParameterSuggestions(slash, partialArg)
    -- If slash is /w, suggest from recent or friends
    if slash:lower() == "/w" then
        local suggestions = {}
        -- Combine known friend names & recent whisper targets
        local combined = {}

        for nameLower in pairs(recentWhispers) do
            table.insert(combined, nameLower)
        end
        for _, name in ipairs(friendNames) do
            combined[#combined + 1] = name:lower()
        end

        local partialLower = partialArg:lower()
        for _, nm in ipairs(combined) do
            if nm:find(partialLower, 1, true) then
                table.insert(suggestions, nm)
            end
        end
        return suggestions
    end

    local subcommands = knownParams[slash:lower()]
    if not subcommands then
        return {}
    end

    local results = {}
    for _, sc in ipairs(subcommands) do
        if sc:lower():find(partialArg:lower(), 1, true) then
            table.insert(results, sc)
        end
    end
    return results
end

function CommandSage_ParameterHelper:GetInlineHint(slash)
    local subcommands = knownParams[slash]
    if not subcommands then
        return nil
    end
    return table.concat(subcommands, " | ")
end

-- Initialize friend list once
C_Timer.After(5, UpdateFriendList)
