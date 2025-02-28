-- File: Modules/CommandSage_Licensing.lua
CommandSage_Licensing = {}
local LICENSE_KEY_DB_FIELD = "licenseKey"

function CommandSage_Licensing:IsProActive()
    if not CommandSage_Config.Get("preferences", "monetizationEnabled") then
        return true
    end
    local key = (CommandSageDB and CommandSageDB[LICENSE_KEY_DB_FIELD]) or nil
    if key and key == "MY-PRO-KEY" then
        return true
    end
    return false
end

function CommandSage_Licensing:HandleLicenseCommand(msg)
    local cmd = msg:match("^(%S+)$") or ""
    if cmd == "" then
        if self:IsProActive() then
            print("CommandSage Pro is ACTIVE.")
        else
            print("CommandSage Pro is NOT active. Enter /license <key>.")
        end
        return
    end
    if not CommandSageDB or type(CommandSageDB) ~= "table" then
        CommandSageDB = {}
    end
    CommandSageDB[LICENSE_KEY_DB_FIELD] = cmd
    if self:IsProActive() then
        print("License accepted. Pro features enabled.")
    else
        print("License invalid or not recognized.")
    end
end

function CommandSage_Licensing:GetLicenseKey()
    if not CommandSageDB then
        return nil
    end
    return CommandSageDB[LICENSE_KEY_DB_FIELD]
end

return CommandSage_Licensing
