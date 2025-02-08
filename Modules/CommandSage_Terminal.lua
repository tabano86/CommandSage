-- File: Modules/CommandSage_Terminal.lua
CommandSage_Terminal = {}

-- Utility: Clamp a value between 0 and 1.
local function clamp(v)
    if v < 0 then
        return 0
    elseif v > 1 then
        return 1
    else
        return v
    end
end

-- Utility: Print messages with a terminal prefix.
local function termPrint(msg)
    print("|cff00ff00[CommandSage Terminal]|r: " .. tostring(msg))
end

-- Utility: Debug logging if CommandSage.debugMode is enabled.
local function debugLog(msg)
    if CommandSage and CommandSage.debugMode then
        print("|cff999999[Terminal Debug]|r " .. tostring(msg))
    end
end

-- Store the start time for uptime calculations.
CommandSage_Terminal.startTime = GetTime() or 0

-- Table of terminal commands.
local terminalCommands = {
    cls = {
        command = "/cls",
        func = function(msg)
            for i = 1, NUM_CHAT_WINDOWS do
                local cf = _G["ChatFrame" .. i]
                if cf and cf:IsVisible() then
                    cf:Clear()
                end
            end
            termPrint("Chat frames cleared.")
        end,
        description = "Clears all visible chat frames."
    },
    lsmacros = {
        command = "/lsmacros",
        func = function(msg)
            local global, char = (GetNumMacros and GetNumMacros()) or 0, (GetNumMacros and select(2, GetNumMacros()) or 0)
            termPrint("Global macros: " .. tostring(global) .. "  Character macros: " .. tostring(char))
        end,
        description = "Lists the number of global and character macros."
    },
    pwd = {
        command = "/pwd",
        func = function(msg)
            local zoneName = GetRealZoneText() or "Unknown"
            local subZone = GetSubZoneText() or ""
            local output = "Current zone: " .. zoneName
            if subZone ~= "" then
                output = output .. ", " .. subZone
            end
            termPrint(output)
        end,
        description = "Displays the current zone and subzone."
    },
    time = {
        command = "/time",
        func = function(msg)
            termPrint("Server time: " .. date("%H:%M:%S"))
        end,
        description = "Displays the current server time."
    },
    uptime = {
        command = "/uptime",
        func = function(msg)
            local uptime = GetTime() - CommandSage_Terminal.startTime
            local hours = math.floor(uptime / 3600)
            local minutes = math.floor((uptime % 3600) / 60)
            local seconds = math.floor(uptime % 60)
            termPrint(string.format("Session uptime: %02d:%02d:%02d", hours, minutes, seconds))
        end,
        description = "Displays the session uptime (hh:mm:ss)."
    },
    version = {
        command = "/version",
        func = function(msg)
            termPrint("CommandSage Terminal v4.3")
            if CommandSage and CommandSage.debugMode then
                termPrint("Debug mode is enabled.")
            end
        end,
        description = "Displays the version information."
    },
    cd = {
        command = "/cd",
        func = function(msg)
            if CommandSage_ShellContext and CommandSage_ShellContext.HandleCd then
                CommandSage_ShellContext:HandleCd(msg)
            else
                termPrint("Shell context module is not available.")
            end
        end,
        description = "Changes the shell context using /cd <context>."
    },
    license = {
        command = "/license",
        func = function(msg)
            if CommandSage_Licensing and CommandSage_Licensing.HandleLicenseCommand then
                CommandSage_Licensing:HandleLicenseCommand(msg)
            else
                termPrint("Licensing module not available.")
            end
        end,
        description = "Handles license commands."
    },
    whoami = {
        command = "/whoami",
        func = function(msg)
            local name = UnitName("player") or "Unknown"
            termPrint("You are: " .. name)
        end,
        description = "Displays your player name."
    },
    donate = {
        command = "/donate",
        func = function(msg)
            termPrint("Thanks for considering a donation! Visit:")
            print("https://www.buymeacoffee.com/anthonytabano")
        end,
        description = "Displays the donation URL."
    },
    coffee = {
        command = "/coffee",
        func = function(msg)
            -- Alias to /donate.
            if SlashCmdList["CMDDONATE"] then
                SlashCmdList["CMDDONATE"](msg)
            else
                termPrint("Donation command is not available.")
            end
        end,
        description = "Alias for /donate."
    },
    color = {
        command = "/color",
        func = function(msg)
            local r, g, b = msg:match("^(%S+)%s+(%S+)%s+(%S+)$")
            if r and g and b then
                local rr = clamp(tonumber(r) or 0)
                local gg = clamp(tonumber(g) or 0)
                local bb = clamp(tonumber(b) or 0)
                termPrint(string.format("Setting chat color to (%.2f, %.2f, %.2f)", rr, gg, bb))
            else
                termPrint("Usage: /color <r> <g> <b> (each between 0 and 1)")
            end
        end,
        description = "Sets the chat text color."
    },
    ["3dspin"] = {
        command = "/3dspin",
        func = function(msg)
            if not WorldFrame then
                termPrint("3D environment not detected.")
                return
            end
            termPrint("Spinning your 3D environment! (Mock)")
        end,
        description = "Simulates a spinning 3D environment."
    },
    help = {
        command = "/helpterm",
        func = function(msg)
            termPrint("Available Terminal Commands:")
            for key, cmdData in pairs(terminalCommands) do
                local enabled = true
                if key == "color" then
                    enabled = CommandSage_Config.Get("preferences", "colorCommandEnabled")
                elseif key == "3dspin" then
                    enabled = CommandSage_Config.Get("preferences", "spin3DEnabled")
                end
                local status = enabled and "" or " (disabled)"
                termPrint(cmdData.command .. " - " .. cmdData.description .. status)
            end
        end,
        description = "Displays this help message."
    },
    ping = {
        command = "/ping",
        func = function(msg)
            local lagHome, lagWorld = 0, 0
            if GetNetStats then
                lagHome, lagWorld = select(3, GetNetStats()) or 0, select(4, GetNetStats()) or 0
            end
            termPrint("Home latency: " .. lagHome .. " ms, World latency: " .. lagWorld .. " ms")
        end,
        description = "Displays network latency."
    }
}

--------------------------------------------------------------------------------
-- Initialize: Registers all terminal commands.
-- This method remains backwards compatible.
--------------------------------------------------------------------------------
function CommandSage_Terminal:Initialize()
    if not CommandSage_Config.Get("preferences", "enableTerminalGoodies") then
        debugLog("Terminal goodies are disabled in preferences.")
        return
    end

    debugLog("Initializing Terminal commands...")

    for key, cmdData in pairs(terminalCommands) do
        -- Conditionally skip commands based on configuration.
        if (key == "color" and not CommandSage_Config.Get("preferences", "colorCommandEnabled"))
                or (key == "3dspin" and not CommandSage_Config.Get("preferences", "spin3DEnabled"))
        then
            debugLog("Skipping command: " .. cmdData.command)
        else
            local globalVar = "SLASH_CMD" .. string.upper(key) .. "1"
            _G[globalVar] = cmdData.command
            SlashCmdList["CMD" .. string.upper(key)] = function(msg)
                debugLog("Executing command: " .. cmdData.command .. " with msg: " .. (msg or ""))
                local success, err = pcall(cmdData.func, msg)
                if not success then
                    termPrint("Error executing " .. cmdData.command .. ": " .. tostring(err))
                end
            end
            debugLog("Registered terminal command: " .. cmdData.command)
        end
    end

    -- Backwards compatibility: ensure /coffee is aliased to /donate.
    if not _G["SLASH_CMDCOFFEE1"] then
        SLASH_CMDCOFFEE1 = "/coffee"
        SlashCmdList["CMDCOFFEE"] = SlashCmdList["CMDDONATE"]
    end

    debugLog("Terminal initialization complete.")
end

return CommandSage_Terminal
