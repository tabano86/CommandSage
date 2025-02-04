-- =============================================================================
-- CommandSage_ParameterHelper.lua
-- Show subcommands, expected args inline (colored differently if desired)
-- =============================================================================

CommandSage_ParameterHelper = {}

local knownParams = {
    ["/dance"] = { "silly", "fancy", "epic" },
    ["/macro"] = { "new", "delete", "edit" },
}

function CommandSage_ParameterHelper:GetParameterSuggestions(slash, partialArg)
    local subcommands = knownParams[slash]
    if not subcommands then
        return {}
    end
    local results = {}
    for _, sc in ipairs(subcommands) do
        if sc:lower():find(partialArg:lower()) then
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
