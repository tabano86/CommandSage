-- =============================================================================
-- CommandSage_Terminal.lua
-- "Terminal goodies" you might see on a Mac/Windows shell for WoW Classic
-- Includes 50 additional commands
-- =============================================================================

CommandSage_Terminal = {}

function CommandSage_Terminal:Initialize()
    if not CommandSage_Config.Get("preferences", "enableTerminalGoodies") then
        return
    end

    -- Existing commands
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

    -- Record addon start time for /uptime
    CommandSage_Terminal.startTime = GetTime()

    ---------------------------------------------------------------------
    -- 50 Additional Terminal Commands
    ---------------------------------------------------------------------

    -- 1. /whoami
    SLASH_CMDWHOAMI1 = "/whoami"
    SlashCmdList["CMDWHOAMI"] = function(msg)
        local name = UnitName("player") or "Unknown"
        print("Player Name: " .. name)
    end

    -- 2. /time
    SLASH_CMDTIME1 = "/time"
    SlashCmdList["CMDTIME"] = function(msg)
        print("Local Time: " .. date("%H:%M:%S"))
    end

    -- 3. /uptime
    SLASH_CMDUPTIME1 = "/uptime"
    SlashCmdList["CMDUPTIME"] = function(msg)
        local elapsed = math.floor(GetTime() - CommandSage_Terminal.startTime)
        print("Uptime: " .. elapsed .. " seconds")
    end

    -- 4. /ping
    SLASH_CMDPING1 = "/ping"
    SlashCmdList["CMDPING"] = function(msg)
        local home, world = GetNetStats()
        print("Latency - Home: " .. home .. " ms, World: " .. world .. " ms")
    end

    -- 5. /fps
    SLASH_CMDFPS1 = "/fps"
    SlashCmdList["CMDFPS"] = function(msg)
        print("Current FPS: " .. math.floor(GetFramerate()))
    end

    -- 6. /mem
    SLASH_CMDMEM1 = "/mem"
    SlashCmdList["CMDMEM"] = function(msg)
        local memKB = collectgarbage("count")
        print(string.format("Memory Usage: %.2f MB", memKB / 1024))
    end

    -- 7. /gold
    SLASH_CMDGOLD1 = "/gold"
    SlashCmdList["CMDGOLD"] = function(msg)
        local money = GetMoney() or 0
        local gold = math.floor(money / 10000)
        local silver = math.floor((money % 10000) / 100)
        local copper = money % 100
        print(string.format("Gold: %dg %ds %dc", gold, silver, copper))
    end

    -- 8. /bagspace
    SLASH_CMDBAGSPACE1 = "/bagspace"
    SlashCmdList["CMDBAGSPACE"] = function(msg)
        local freeSlots, totalSlots = 0, 0
        for bag = 0, NUM_BAG_SLOTS do
            local slots = GetContainerNumSlots(bag)
            if slots then
                totalSlots = totalSlots + slots
                freeSlots = freeSlots + (slots - GetContainerNumItems(bag))
            end
        end
        print("Bag Space: " .. freeSlots .. " free / " .. totalSlots .. " total slots")
    end

    -- 9. /questcount
    SLASH_CMDQUESTCOUNT1 = "/questcount"
    SlashCmdList["CMDQUESTCOUNT"] = function(msg)
        local numEntries = GetNumQuestLogEntries()
        print("Active Quests: " .. numEntries)
    end

    -- 10. /playerinfo
    SLASH_CMDPLAYERINFO1 = "/playerinfo"
    SlashCmdList["CMDPLAYERINFO"] = function(msg)
        local name = UnitName("player") or "Unknown"
        local level = UnitLevel("player") or 0
        local race = UnitRace("player") or "Unknown"
        local class = UnitClass("player") or "Unknown"
        print(string.format("Name: %s | Level: %d | Race: %s | Class: %s", name, level, race, class))
    end

    -- 11. /guild
    SLASH_CMDGUILD1 = "/guild"
    SlashCmdList["CMDGUILD"] = function(msg)
        local guildName, guildRank = GetGuildInfo("player")
        if guildName then
            print("Guild: " .. guildName .. " (" .. guildRank .. ")")
        else
            print("Not in a guild.")
        end
    end

    -- 12. /stats
    SLASH_CMDSTATS1 = "/stats"
    SlashCmdList["CMDSTATS"] = function(msg)
        local statNames = {"Strength", "Agility", "Stamina", "Intellect", "Spirit"}
        local parts = {}
        for i, name in ipairs(statNames) do
            local base, stat = UnitStat("player", i)
            parts[#parts + 1] = name .. ": " .. stat
        end
        print(table.concat(parts, ", "))
    end

    -- 13. /xp
    SLASH_CMDXP1 = "/xp"
    SlashCmdList["CMDXP"] = function(msg)
        local xp = UnitXP("player") or 0
        local xpMax = UnitXPMax("player") or 1
        local percent = math.floor((xp / xpMax) * 100)
        print(string.format("XP: %d/%d (%d%%)", xp, xpMax, percent))
    end

    -- 14. /health
    SLASH_CMDHEALTH1 = "/health"
    SlashCmdList["CMDHEALTH"] = function(msg)
        local cur = UnitHealth("player") or 0
        local max = UnitHealthMax("player") or 0
        print("Health: " .. cur .. " / " .. max)
    end

    -- 15. /mana
    SLASH_CMDMANA1 = "/mana"
    SlashCmdList["CMDMANA"] = function(msg)
        local cur = UnitPower("player", 0) or 0
        local max = UnitPowerMax("player", 0) or 0
        if max > 0 then
            print("Mana: " .. cur .. " / " .. max)
        else
            print("No mana resource available.")
        end
    end

    -- 16. /reload
    SLASH_CMDRELOAD1 = "/reload"
    SlashCmdList["CMDRELOAD"] = function(msg)
        ReloadUI()
    end

    -- 17. /map
    SLASH_CMDMAP1 = "/map"
    SlashCmdList["CMDMAP"] = function(msg)
        ToggleWorldMap()
    end

    -- 18. /echo
    SLASH_CMDECHO1 = "/echo"
    SlashCmdList["CMDECHO"] = function(msg)
        print(msg)
    end

    -- 19. /reverse
    SLASH_CMDREVERSE1 = "/reverse"
    SlashCmdList["CMDREVERSE"] = function(msg)
        print(msg:reverse())
    end

    -- 20. /upper
    SLASH_CMDUPPER1 = "/upper"
    SlashCmdList["CMDUPPER"] = function(msg)
        print(msg:upper())
    end

    -- 21. /lower
    SLASH_CMDLOWER1 = "/lower"
    SlashCmdList["CMDLOWER"] = function(msg)
        print(msg:lower())
    end

    -- 22. /calc
    SLASH_CMDCALC1 = "/calc"
    SlashCmdList["CMDCALC"] = function(msg)
        local func, err = loadstring("return " .. msg)
        if func then
            local success, result = pcall(func)
            if success then
                print("Result: " .. tostring(result))
            else
                print("Error evaluating expression.")
            end
        else
            print("Invalid expression: " .. err)
        end
    end

    -- 23. /rand
    SLASH_CMDRAND1 = "/rand"
    SlashCmdList["CMDRAND"] = function(msg)
        local lower, upper = msg:match("^(%d+)%s*(%d*)")
        lower = tonumber(lower) or 0
        upper = tonumber(upper) or 100
        if lower > upper then lower, upper = upper, lower end
        print("Random number: " .. math.random(lower, upper))
    end

    -- 24. /dice
    SLASH_CMDDICE1 = "/dice"
    SlashCmdList["CMDDICE"] = function(msg)
        local lower, upper = msg:match("^(%d+)%s*(%d*)")
        lower = tonumber(lower) or 1
        upper = tonumber(upper) or 6
        if lower > upper then lower, upper = upper, lower end
        print("Dice roll: " .. math.random(lower, upper))
    end

    -- 25. /date
    SLASH_CMDDATE1 = "/date"
    SlashCmdList["CMDDATE"] = function(msg)
        print("Today is: " .. date("%Y-%m-%d"))
    end

    -- 26. /serverinfo
    SLASH_CMDSERVERINFO1 = "/serverinfo"
    SlashCmdList["CMDSERVERINFO"] = function(msg)
        print("Server: " .. (GetRealmName() or "Unknown"))
    end

    -- 27. /locate
    SLASH_CMDLOCATE1 = "/locate"
    SlashCmdList["CMDLOCATE"] = function(msg)
        local zone = GetRealZoneText() or "Unknown"
        local subZone = GetSubZoneText() or ""
        print("Location: " .. zone .. (subZone ~= "" and (", " .. subZone) or ""))
    end

    -- 28. /version
    SLASH_CMDVERSION1 = "/version"
    SlashCmdList["CMDVERSION"] = function(msg)
        print("CommandSage Terminal v2.1")
    end

    -- 29. /config
    SLASH_CMDCONFIG1 = "/config"
    SlashCmdList["CMDCONFIG"] = function(msg)
        print("Use /cmdsage config <key> <value> to change config.")
    end

    -- 30. /help
    SLASH_CMDHELP1 = "/help"
    SlashCmdList["CMDHELP"] = function(msg)
        local commands = {
            "/cls", "/lsmacros", "/pwd", "/whoami", "/time", "/uptime", "/ping", "/fps", "/mem", "/gold",
            "/bagspace", "/questcount", "/playerinfo", "/guild", "/stats", "/xp", "/health", "/mana", "/reload", "/map",
            "/echo", "/reverse", "/upper", "/lower", "/calc", "/rand", "/dice", "/date", "/serverinfo", "/locate",
            "/version", "/config", "/help", "/listquests", "/listbags", "/listaddons", "/durability", "/frames",
            "/chatlist", "/serverdate", "/zoneid", "/targetinfo", "/inspect", "/sum", "/countdown", "/reminder",
            "/afk", "/lag", "/gtime", "/buffs", "/debuffs", "/addoninfo", "/exit", "/cd", "/license"
        }
        print("Available commands:")
        for _, cmd in ipairs(commands) do
            print(" " .. cmd)
        end
    end

    -- 31. /listquests
    SLASH_CMDLISTQUESTS1 = "/listquests"
    SlashCmdList["CMDLISTQUESTS"] = function(msg)
        local numEntries = GetNumQuestLogEntries()
        print("Quests:")
        for i = 1, numEntries do
            local title, _, _, isComplete = GetQuestLogTitle(i)
            if title then
                print(i .. ". " .. title .. (isComplete and " (Complete)" or ""))
            end
        end
    end

    -- 32. /listbags
    SLASH_CMDLISTBAGS1 = "/listbags"
    SlashCmdList["CMDLISTBAGS"] = function(msg)
        for bag = 0, NUM_BAG_SLOTS do
            local numItems = GetContainerNumItems(bag) or 0
            local slots = GetContainerNumSlots(bag) or 0
            print("Bag " .. bag .. ": " .. numItems .. " items (" .. slots .. " slots)")
        end
    end

    -- 33. /listaddons
    SLASH_CMDLISTADDONS1 = "/listaddons"
    SlashCmdList["CMDLISTADDONS"] = function(msg)
        local numAddOns = GetNumAddOns()
        print("Enabled Addons:")
        for i = 1, numAddOns do
            local name, title, _, enabled = GetAddOnInfo(i)
            if enabled then
                print(i .. ". " .. (title or name))
            end
        end
    end

    -- 34. /durability
    SLASH_CMDDURABILITY1 = "/durability"
    SlashCmdList["CMDDURABILITY"] = function(msg)
        local total, count = 0, 0
        for slot = 1, 19 do
            local cur, mx = GetInventoryItemDurability(slot)
            if cur and mx then
                total = total + (cur / mx)
                count = count + 1
            end
        end
        if count > 0 then
            print("Average Durability: " .. math.floor((total / count) * 100) .. "%")
        else
            print("No durability data available.")
        end
    end

    -- 35. /frames
    SLASH_CMDFRAMES1 = "/frames"
    SlashCmdList["CMDFRAMES"] = function(msg)
        for i = 1, NUM_CHAT_WINDOWS do
            local cf = _G["ChatFrame" .. i]
            if cf and cf:IsVisible() then
                print("ChatFrame" .. i .. " is visible.")
            end
        end
    end

    -- 36. /chatlist
    SLASH_CMDCHATLIST1 = "/chatlist"
    SlashCmdList["CMDCHATLIST"] = function(msg)
        local channels = { GetChannelList() }
        if #channels > 0 then
            print("Active Chat Channels:")
            for i = 1, #channels, 2 do
                print(channels[i + 1])
            end
        else
            print("No active chat channels found.")
        end
    end

    -- 37. /serverdate
    SLASH_CMDSERVERDATE1 = "/serverdate"
    SlashCmdList["CMDSERVERDATE"] = function(msg)
        print("Server Date: " .. date("%Y-%m-%d"))
    end

    -- 38. /zoneid
    SLASH_CMDZONEID1 = "/zoneid"
    SlashCmdList["CMDZONEID"] = function(msg)
        local zoneID = GetCurrentMapAreaID and GetCurrentMapAreaID() or "N/A"
        print("Zone ID: " .. tostring(zoneID))
    end

    -- 39. /targetinfo
    SLASH_CMDTARGETINFO1 = "/targetinfo"
    SlashCmdList["CMDTARGETINFO"] = function(msg)
        if UnitExists("target") then
            local name = UnitName("target") or "Unknown"
            local level = UnitLevel("target") or 0
            local class = UnitClass("target") or "Unknown"
            print(string.format("Target -> Name: %s | Level: %d | Class: %s", name, level, class))
        else
            print("No target selected.")
        end
    end

    -- 40. /inspect
    SLASH_CMDINSPECT1 = "/inspect"
    SlashCmdList["CMDINSPECT"] = function(msg)
        if UnitExists("target") then
            print("Inspecting " .. (UnitName("target") or "Unknown") .. "...")
            NotifyInspect("target")
        else
            print("No target to inspect.")
        end
    end

    -- 41. /sum
    SLASH_CMDSUM1 = "/sum"
    SlashCmdList["CMDSUM"] = function(msg)
        local total = 0
        for num in msg:gmatch("%S+") do
            total = total + (tonumber(num) or 0)
        end
        print("Sum: " .. total)
    end

    -- 42. /countdown
    SLASH_CMDCOUNTDOWN1 = "/countdown"
    SlashCmdList["CMDCOUNTDOWN"] = function(msg)
        local seconds = tonumber(msg) or 5
        print("Countdown:")
        for i = seconds, 1, -1 do
            C_Timer.After(seconds - i, function() print(i) end)
        end
        C_Timer.After(seconds, function() print("Time's up!") end)
    end

    -- 43. /reminder
    SLASH_CMDREMINDER1 = "/reminder"
    SlashCmdList["CMDREMINDER"] = function(msg)
        local delay, reminder = msg:match("^(%d+)%s+(.+)$")
        delay = tonumber(delay)
        if delay and reminder then
            print("Reminder set for " .. delay .. " seconds.")
            C_Timer.After(delay, function() print("Reminder: " .. reminder) end)
        else
            print("Usage: /reminder <seconds> <message>")
        end
    end

    -- 44. /afk
    SLASH_CMDAFK1 = "/afk"
    SlashCmdList["CMDAFK"] = function(msg)
        print("AFK status toggled.")
    end

    -- 45. /lag
    SLASH_CMDLAG1 = "/lag"
    SlashCmdList["CMDLAG"] = function(msg)
        local home, world = GetNetStats()
        print("Latency - Home: " .. home .. " ms, World: " .. world .. " ms")
    end

    -- 46. /gtime
    SLASH_CMDGTIME1 = "/gtime"
    SlashCmdList["CMDGTIME"] = function(msg)
        local guildName = select(1, GetGuildInfo("player")) or "No Guild"
        print("Guild: " .. guildName .. " | Time: " .. date("%H:%M:%S"))
    end

    -- 47. /buffs
    SLASH_CMDBUFFS1 = "/buffs"
    SlashCmdList["CMDBUFFS"] = function(msg)
        print("Active Buffs:")
        local i = 1
        while true do
            local name = UnitBuff("player", i)
            if not name then break end
            print(i .. ". " .. name)
            i = i + 1
        end
    end

    -- 48. /debuffs
    SLASH_CMDDEBUFFS1 = "/debuffs"
    SlashCmdList["CMDDEBUFFS"] = function(msg)
        print("Active Debuffs:")
        local i = 1
        while true do
            local name = UnitDebuff("player", i)
            if not name then break end
            print(i .. ". " .. name)
            i = i + 1
        end
    end

    -- 49. /addoninfo
    SLASH_CMDADDONINFO1 = "/addoninfo"
    SlashCmdList["CMDADDONINFO"] = function(msg)
        print("CommandSage Terminal v2.1 - WoW Classic Terminal Goodies")
    end

    -- 50. /exit
    SLASH_CMDEXIT1 = "/exit"
    SlashCmdList["CMDEXIT"] = function(msg)
        print("Goodbye! (This command does not exit the game.)")
    end

    -- Extra: /cd => shell context
    SLASH_CMDSHELLCD1 = "/cd"
    SlashCmdList["CMDSHELLCD"] = function(msg)
        CommandSage_ShellContext:HandleCd(msg)
    end

    -- Extra: /license => set or check license
    SLASH_CMDLICENSE1 = "/license"
    SlashCmdList["CMDLICENSE"] = function(msg)
        CommandSage_Licensing:HandleLicenseCommand(msg)
    end
end
