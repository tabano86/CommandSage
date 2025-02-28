-- File: Modules/CommandSage_FuzzyMatch.lua
CommandSage_FuzzyMatch = {}
local cache = {}

function CommandSage_FuzzyMatch:ClearCache()
    cache = {}
end

-- Levenshtein distance with caching.
local function Levenshtein(a, b)
    local key = a .. "|" .. b
    if cache[key] then
        return cache[key]
    end
    local la, lb = #a, #b
    if la == 0 then
        cache[key] = lb
        return lb
    end
    if lb == 0 then
        cache[key] = la
        return la
    end
    local matrix = {}
    for i = 0, la do
        matrix[i] = {}
        matrix[i][0] = i
    end
    for j = 0, lb do
        matrix[0][j] = j
    end
    for i = 1, la do
        for j = 1, lb do
            local cost = (a:sub(i, i) == b:sub(j, j)) and 0 or 1
            matrix[i][j] = math.min(
                    matrix[i - 1][j] + 1,
                    matrix[i][j - 1] + 1,
                    matrix[i - 1][j - 1] + cost
            )
        end
    end
    local dist = matrix[la][lb]
    cache[key] = dist
    return dist
end

local function getContextBonus()
    if InCombatLockdown() then
        return -1
    end
    return 0
end

-- In GetSuggestions, if the candidate command starts with the input,
-- we treat the distance as 0. This ensures that typing "/re" will match "/reload".
function CommandSage_FuzzyMatch:GetSuggestions(input, possibleCommands)
    local tolerance = CommandSage_Config.Get("preferences", "fuzzyMatchTolerance") or 2
    local results = {}
    input = input:lower()
    for _, cmdObj in ipairs(possibleCommands) do
        local slash = cmdObj.slash
        local dist = 0
        if slash:sub(1, #input) == input then
            dist = 0
        else
            dist = Levenshtein(slash, input)
        end
        if dist <= tolerance then
            local usageScore = CommandSage_AdaptiveLearning:GetUsageScore(slash)
            local cBonus = getContextBonus()
            local rank = -dist + (usageScore * 0.7) + cBonus
            table.insert(results, {
                slash = slash,
                data = cmdObj.data,
                rank = rank,
                distance = dist
            })
        end
    end
    table.sort(results, function(a, b)
        return a.rank > b.rank
    end)
    return results
end

function CommandSage_FuzzyMatch:SuggestCorrections(input)
    local discovered = CommandSage_Discovery:GetDiscoveredCommands() or {}
    local bestDist = math.huge
    local bestCmd = nil
    input = input:lower()
    for slash, _ in pairs(discovered) do
        local d = 0
        if slash:sub(1, #input) == input then
            d = 0
        else
            d = Levenshtein(slash, input)
        end
        if d < bestDist then
            bestDist = d
            bestCmd = slash
        end
    end
    if bestCmd and type(bestCmd) == "table" then
        bestCmd = bestCmd.slash
    end
    if bestDist <= ((CommandSage_Config.Get("preferences", "fuzzyMatchTolerance") or 2) + 1) then
        return bestCmd, bestDist
    end
    return nil, bestDist
end

function CommandSage_FuzzyMatch:GetFuzzyDistance(strA, strB)
    return Levenshtein(strA:lower(), strB:lower())
end

return CommandSage_FuzzyMatch
