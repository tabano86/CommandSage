-- =============================================================================
-- CommandSage_ParameterHelper.lua
-- Sub-command suggestions (e.g., /dance fancy)
-- =============================================================================

CommandSage_ParameterHelper = {}

local knownParams = {
    ["/dance"]  = { "silly", "fancy", "epic" },
    ["/macro"]  = { "new", "delete", "edit" },
    ["/help"]   = { "advanced", "commands", "tips" },
}

local recentWhispers = {}
local friendNames = {}

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

function CommandSage_ParameterHelper:RecordWhisperTarget(targetName)
    if targetName and targetName ~= "" then
        recentWhispers[targetName:lower()] = true
    end
end

function CommandSage_ParameterHelper:GetParameterSuggestions(slash, partialArg)
    if slash:lower() == "/w" then
        local suggestions = {}
        local combined = {}
        for nameLower in pairs(recentWhispers) do
            table.insert(combined, nameLower)
        end
        for _, name in ipairs(friendNames) do
            table.insert(combined, name:lower())
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

C_Timer.After(5, UpdateFriendList)

function CommandSage_ParameterHelper:AddKnownParam(slash, param)
    slash = slash:lower()
    if not knownParams[slash] then
        knownParams[slash] = {}
    end
    table.insert(knownParams[slash], param)
end
