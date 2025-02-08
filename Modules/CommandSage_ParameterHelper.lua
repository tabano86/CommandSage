-- File: Modules/CommandSage_ParameterHelper.lua
CommandSage_ParameterHelper = {}

--------------------------------------------------
-- Internal Data and Caches
--------------------------------------------------
local knownParams = {
    ["/dance"] = { "silly", "fancy", "epic" },
    ["/macro"] = { "new", "delete", "edit" },
    ["/help"]  = { "advanced", "commands", "tips" },
}
-- Cache for dynamically added parameters (e.g. from external plugins)
local dynamicParams = {}

-- Cache for friend names and recent whispers
local recentWhispers = {}  -- keys are lower-case names
local friendNames = {}     -- cached friend names (all lower-case)
local friendCacheLastUpdate = 0
local FRIEND_CACHE_INTERVAL = 10  -- seconds

-- Cache for suggestion results (keyed by: slash|partialArg)
local suggestionCache = {}

--------------------------------------------------
-- Utility Functions
--------------------------------------------------
-- Simple debug logging (if CommandSage.debugMode is enabled)
local function debugLog(msg)
    if CommandSage and CommandSage.debugMode then
        print("|cff999999[ParamHelper Debug]|r " .. tostring(msg))
    end
end

-- Merges two tables into a set (keys are the items, values true)
local function mergeIntoSet(t1, t2)
    local set = {}
    if t1 then
        for _, v in ipairs(t1) do
            set[v] = true
        end
    end
    if t2 then
        for _, v in ipairs(t2) do
            set[v] = true
        end
    end
    return set
end

-- Converts a set (table with keys) into a sorted list
local function setToSortedList(set)
    local list = {}
    for k in pairs(set) do
        table.insert(list, k)
    end
    table.sort(list)
    return list
end

--------------------------------------------------
-- Public API Functions
--------------------------------------------------

-- Exposes the static and dynamic parameter table.
-- (Dynamic parameters from AddKnownParam are merged into knownParams.)
function CommandSage_ParameterHelper:ExposeKnownParams()
    local merged = {}
    for slash, params in pairs(knownParams) do
        merged[slash] = {}
        for _, p in ipairs(params) do
            table.insert(merged[slash], p)
        end
    end
    for slash, params in pairs(dynamicParams) do
        if not merged[slash] then
            merged[slash] = {}
        end
        for _, p in ipairs(params) do
            table.insert(merged[slash], p)
        end
    end
    return merged
end

-- Updates the friend list cache.
local function UpdateFriendList()
    local currentTime = GetTime() or 0
    if currentTime - friendCacheLastUpdate < FRIEND_CACHE_INTERVAL then
        return  -- use cached friend names
    end
    friendCacheLastUpdate = currentTime
    wipe(friendNames)
    if C_FriendList and C_FriendList.GetNumFriends then
        local numFriends = C_FriendList.GetNumFriends() or 0
        for i = 1, numFriends do
            local fi = C_FriendList.GetFriendInfoByIndex(i)
            if fi and fi.name then
                table.insert(friendNames, fi.name:lower())
            end
        end
    end
    debugLog("Friend list updated with " .. #friendNames .. " names.")
end

-- Records a whisper target (stores in recentWhispers)
function CommandSage_ParameterHelper:RecordWhisperTarget(targetName)
    if targetName and targetName ~= "" then
        recentWhispers[targetName:lower()] = true
        debugLog("Recorded whisper target: " .. targetName:lower())
    end
end

-- Returns parameter suggestions based on the command (slash) and the partial argument.
-- For /w (whisper), merges recent whispers and friend names, removes duplicates and sorts.
function CommandSage_ParameterHelper:GetParameterSuggestions(slash, partialArg)
    local lowerSlash = slash:lower()
    local lowerPartial = partialArg and partialArg:lower() or ""
    local cacheKey = lowerSlash .. "|" .. lowerPartial
    if suggestionCache[cacheKey] then
        debugLog("Returning cached suggestions for key: " .. cacheKey)
        return suggestionCache[cacheKey]
    end

    local results = {}
    -- Special handling for whisper commands:
    if lowerSlash == "/w" then
        UpdateFriendList()
        local combinedSet = mergeIntoSet(
                setToSortedList({}),  -- dummy call; we'll fill manually below
                nil
        )
        -- Insert recent whispers
        for nm in pairs(recentWhispers) do
            combinedSet[nm] = true
        end
        -- Insert friend names (which are already lower-case)
        for _, name in ipairs(friendNames) do
            combinedSet[name] = true
        end
        local combinedList = setToSortedList(combinedSet)
        for _, nm in ipairs(combinedList) do
            if lowerPartial == "" or nm:find(lowerPartial, 1, true) then
                table.insert(results, nm)
            end
        end
    else
        -- Merge static and dynamic parameters for the given slash.
        local subs = knownParams[lowerSlash] or {}
        local dyn = dynamicParams[lowerSlash] or {}
        local allSubs = {}
        for _, p in ipairs(subs) do
            table.insert(allSubs, p)
        end
        for _, p in ipairs(dyn) do
            table.insert(allSubs, p)
        end

        for _, sc in ipairs(allSubs) do
            if lowerPartial == "" or sc:lower():find(lowerPartial, 1, true) then
                table.insert(results, sc)
            end
        end
    end

    suggestionCache[cacheKey] = results
    debugLog("Cached " .. #results .. " suggestions for key: " .. cacheKey)
    return results
end

-- Returns an inline hint string (parameters separated by " | ").
-- If a partial argument is provided, the matching parameter (if any) is highlighted with asterisks.
function CommandSage_ParameterHelper:GetInlineHint(slash, partialArg)
    local lowerSlash = slash:lower()
    local params = knownParams[lowerSlash]
    if not params then
        return nil
    end
    local lowerPartial = partialArg and partialArg:lower() or ""
    local hints = {}
    for _, param in ipairs(params) do
        if lowerPartial ~= "" and param:lower():find(lowerPartial, 1, true) then
            table.insert(hints, "*" .. param .. "*")
        else
            table.insert(hints, param)
        end
    end
    return table.concat(hints, " | ")
end

-- Schedules an initial update of the friend list.
if _G.__COMMANDSAGE_TEST_ENV_LOADED then
    UpdateFriendList()
else
    C_Timer.After(5, UpdateFriendList)
end

-- Adds a new known parameter for a given slash command.
-- The new parameter is added to dynamicParams to avoid modifying the original knownParams table.
function CommandSage_ParameterHelper:AddKnownParam(slash, param)
    local lowerSlash = slash:lower()
    if not dynamicParams[lowerSlash] then
        dynamicParams[lowerSlash] = {}
    end
    table.insert(dynamicParams[lowerSlash], param)
    -- Invalidate any cache entries for this slash.
    for key in pairs(suggestionCache) do
        if key:sub(1, #lowerSlash) == lowerSlash then
            suggestionCache[key] = nil
        end
    end
    debugLog("Added new parameter '" .. param .. "' for command " .. lowerSlash)
end

return CommandSage_ParameterHelper
