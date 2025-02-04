-- =============================================================================
-- CommandSage_Fallback.lua
-- Allows toggling or reverting to default slash command behavior
-- =============================================================================

CommandSage_Fallback = {}

local fallbackActive = false

function CommandSage_Fallback:EnableFallback()
    fallbackActive = true
end

function CommandSage_Fallback:DisableFallback()
    fallbackActive = false
end

function CommandSage_Fallback:IsFallbackActive()
    return fallbackActive
end
