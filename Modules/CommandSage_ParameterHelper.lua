-- =============================================================================
-- CommandSage_ParameterHelper.lua
-- Suggests subcommands or parameters once a slash command is matched
-- =============================================================================

CommandSage_ParameterHelper = {}

function CommandSage_ParameterHelper:GetParameterSuggestions(commandData, partialArg)
    if not commandData then return {} end
    local results = {}
    if commandData.subcommands then
        for _, subc in ipairs(commandData.subcommands) do
            if subc:find(partialArg) then
                table.insert(results, subc)
            end
        end
    end
    return results
end
