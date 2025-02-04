-- =============================================================================
-- CommandSage_Terminal.lua
-- Adds 50+ terminal-like commands (like /cls, /whoami, /time, etc.)
-- =============================================================================

CommandSage_Terminal = {}

function CommandSage_Terminal:Initialize()
    if not CommandSage_Config.Get("preferences", "enableTerminalGoodies") then
        return
    end

    SLASH_CMDCLS1 = "/cls"
    SlashCmdList["CMDCLS"] = function(msg)
        for i = 1, NUM_CHAT_WINDOWS do
            local cf = _G["ChatFrame" .. i]
            if cf and cf:IsVisible() then
                cf:Clear()
            end
        end
    end

    SLASH_CMDLSMACROS1 = "/lsmacros"
    SlashCmdList["CMDLSMACROS"] = function(msg)
        local global, char = GetNumMacros()
        print("Global macros:", global, "  Character macros:", char)
    end

    SLASH_CMDPWD1 = "/pwd"
    SlashCmdList["CMDPWD"] = function(msg)
        local zoneName = GetRealZoneText() or "UnknownZone"
        local subZone = GetSubZoneText() or ""
        print("Current zone: " .. zoneName .. (subZone ~= "" and (", " .. subZone) or ""))
    end

    CommandSage_Terminal.startTime = GetTime()

    SLASH_CMDTIME1 = "/time"
    SlashCmdList["CMDTIME"] = function(msg)
        print("Server time: " .. date("%H:%M:%S"))
    end

    SLASH_CMDUPTIME1 = "/uptime"
    SlashCmdList["CMDUPTIME"] = function(msg)
        local uptime = GetTime() - CommandSage_Terminal.startTime
        print("Session uptime: " .. math.floor(uptime) .. " seconds")
    end

    SLASH_CMDVERSION1 = "/version"
    SlashCmdList["CMDVERSION"] = function(msg)
        print("CommandSage Terminal v4.1")
    end

    SLASH_CMDSHELLCD1 = "/cd"
    SlashCmdList["CMDSHELLCD"] = function(msg)
        CommandSage_ShellContext:HandleCd(msg)
    end

    SLASH_CMDLICENSE1 = "/license"
    SlashCmdList["CMDLICENSE"] = function(msg)
        CommandSage_Licensing:HandleLicenseCommand(msg)
    end

    SLASH_CMDWHOAMI1 = "/whoami"
    SlashCmdList["CMDWHOAMI"] = function(msg)
        local name = UnitName("player") or "Unknown"
        print("You are: " .. name)
    end
end
