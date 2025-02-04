-- =============================================================================
-- CommandSage_Licensing.lua
-- Simple licensing stub for gating "pro" features
-- =============================================================================

CommandSage_Licensing = {}

local LICENSE_KEY_DB_FIELD = "licenseKey"

-- Check or retrieve license
function CommandSage_Licensing:IsProActive()
    if not CommandSage_Config.Get("preferences", "monetizationEnabled") then
        return true  -- If monetization not used, everything is free
    end
    local key = CommandSageDB[LICENSE_KEY_DB_FIELD]
    -- Simple check (replace with your real validation or server check)
    if key and key == "MY-PRO-KEY" then
        return true
    end
    return false
end

function CommandSage_Licensing:HandleLicenseCommand(msg)
    local cmd = msg:match("^(%S+)$") or ""
    if cmd == "" then
        -- show current status
        if self:IsProActive() then
            print("CommandSage Pro is ACTIVE.")
        else
            print("CommandSage Pro is NOT active. Enter /license <key> to activate.")
        end
        return
    end

    -- user typed a key
    CommandSageDB[LICENSE_KEY_DB_FIELD] = cmd
    if self:IsProActive() then
        print("License accepted. Pro features enabled.")
    else
        print("License invalid or not recognized.")
    end
end
