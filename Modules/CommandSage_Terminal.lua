-- =============================================================================
-- CommandSage_Terminal.lua
-- Adds 50+ terminal-like commands + new /3dspin and /color
-- =============================================================================

CommandSage_Terminal = {}

local function clamp(v)
    if v < 0 then return 0 end
    if v > 1 then return 1 end
    return v
end

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
        print("CommandSage Terminal v4.3")
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

    -- Donation
    SLASH_CMDDONATE1 = "/donate"
    SlashCmdList["CMDDONATE"] = function(msg)
        print("|cff00ff00[CommandSage]|r: Thanks for considering a donation! Visit:")
        print("https://www.buymeacoffee.com/anthonytabano")
    end
    SLASH_CMDCOFFEE1 = "/coffee"
    SlashCmdList["CMDCOFFEE"] = SlashCmdList["CMDDONATE"]

    -- 8) /color <r> <g> <b>
    if CommandSage_Config.Get("preferences", "colorCommandEnabled") then
        SLASH_CMDCOLOR1 = "/color"
        SlashCmdList["CMDCOLOR"] = function(msg)
            local r, g, b = msg:match("^(%S+)%s+(%S+)%s+(%S+)$")
            if r and g and b then
                local rr = clamp(tonumber(r) or 0)
                local gg = clamp(tonumber(g) or 0)
                local bb = clamp(tonumber(b) or 0)
                print(string.format("Setting chat color to (%.2f,%.2f,%.2f)", rr,gg,bb))
                -- Example stub: could set a custom chat color if supported
            else
                print("Usage: /color <r> <g> <b>, each 0..1")
            end
        end
    end

    -- 9) /3dspin
    if CommandSage_Config.Get("preferences", "spin3DEnabled") then
        SLASH_CMD3DSPIN1 = "/3dspin"
        SlashCmdList["CMD3DSPIN"] = function(msg)
            if not WorldFrame then
                print("3D environment not detected. Skipping spin.")
                return
            end
            -- Minimal example
            print("Spinning your 3D environment! (Mock)")
            -- Real code might manipulate camera or model frames
        end
    end
end
