CommandSage_FuzzyMatch = {}
local cache = {}
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
function CommandSage_FuzzyMatch:GetSuggestions(input, possibleCommands)
    local tolerance = CommandSage_Config.Get("preferences", "fuzzyMatchTolerance") or 2
    local results = {}
    for _, cmdObj in ipairs(possibleCommands) do
        local slash = cmdObj.slash
        local dist = Levenshtein(slash, input)
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
    local discovered = CommandSage_Discovery:GetDiscoveredCommands()
    local bestDist = math.huge
    local bestCmd = nil
    for slash, _ in pairs(discovered) do
        local d = Levenshtein(slash, input)
        if d < bestDist then
            bestDist = d
            bestCmd = slash
        end
    end
    if bestDist <= (CommandSage_Config.Get("preferences", "fuzzyMatchTolerance") or 2) + 1 then
        return bestCmd, bestDist
    end
    return nil, bestDist
end
function CommandSage_FuzzyMatch:GetFuzzyDistance(strA, strB)
    return Levenshtein(strA:lower(), strB:lower())
end
