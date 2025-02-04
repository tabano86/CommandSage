-- =============================================================================
-- CommandSage_Fallback.lua
-- Allows toggling fallback mode if auto-suggestions fail
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

function CommandSage_Fallback:ToggleFallback()
    fallbackActive = not fallbackActive
    print("Fallback is now", fallbackActive and "ENABLED" or "DISABLED")
end
