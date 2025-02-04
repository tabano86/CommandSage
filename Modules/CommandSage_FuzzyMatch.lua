-- =============================================================================
-- CommandSage_FuzzyMatch.lua
-- Levenshtein-based fuzzy matching
-- =============================================================================

CommandSage_FuzzyMatch = {}

local function Levenshtein(a, b)
    local lenA, lenB = #a, #b
    if lenA == 0 then return lenB end
    if lenB == 0 then return lenA end

    local matrix = {}
    for i=0,lenA do
        matrix[i] = {}
        matrix[i][0] = i
    end
    for j=0,lenB do
        matrix[0][j] = j
    end

    for i=1,lenA do
        for j=1,lenB do
            local cost = (a:sub(i,i) == b:sub(j,j)) and 0 or 1
            matrix[i][j] = math.min(
                    matrix[i-1][j] + 1,    -- deletion
                    matrix[i][j-1] + 1,    -- insertion
                    matrix[i-1][j-1] + cost -- substitution
            )
        end
    end
    return matrix[lenA][lenB]
end

function CommandSage_FuzzyMatch:GetSuggestions(input, possibleCommands)
    local tol = CommandSage_Config.Get("preferences","fuzzyMatchTolerance") or 2
    local results = {}

    for _, cmdObj in ipairs(possibleCommands) do
        local slash = cmdObj.slash
        local dist = Levenshtein(slash, input)
        if dist <= tol then
            local usageScore = CommandSage_AdaptiveLearning:GetUsageScore(slash)
            local rank = -dist + usageScore * 0.5
            table.insert(results, { slash=slash, data=cmdObj.data, rank=rank })
        end
    end
    table.sort(results, function(a,b) return a.rank > b.rank end)
    return results
end
