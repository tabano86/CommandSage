-- tests/test_HistoryPlayback.lua
-- 10 tests for Core.CommandSage_HistoryPlayback

require("busted.runner")()
require("Modules.CommandSage_HistoryPlayback")
require("Core.CommandSage_Config")

describe("Module: CommandSage_HistoryPlayback", function()

    before_each(function()
        _G.CommandSageDB = {}
        CommandSage_Config:InitializeDefaults()
    end)

    it("AddToHistory won't store anything if persistHistory=false", function()
        CommandSage_Config.Set("preferences", "persistHistory", false)
        CommandSage_HistoryPlayback:AddToHistory("/dance")
        local hist = CommandSageDB.commandHistory
        assert.is_nil(hist)
    end)

    it("AddToHistory appends command if persistHistory=true", function()
        CommandSage_Config.Set("preferences", "persistHistory", true)
        CommandSage_HistoryPlayback:AddToHistory("/dance")
        local hist = CommandSageDB.commandHistory
        assert.equals("/dance", hist[#hist])
    end)

    it("GetHistory returns table even if empty", function()
        local h = CommandSage_HistoryPlayback:GetHistory()
        assert.is_table(h)
        assert.equals(0, #h)
    end)

    it("exceeding maxHist removes earliest entry", function()
        CommandSage_Config.Set("preferences", "persistHistory", true)
        for i = 1, 300 do
            CommandSage_HistoryPlayback:AddToHistory("/cmd" .. i)
        end
        local hist = CommandSage_HistoryPlayback:GetHistory()
        assert.is_true(#hist <= 200)  -- default maxHist = 200
        assert.equals("/cmd101", hist[1])  -- the earliest 100 dropped
    end)

    it("/cmdsagehistory prints the entire history", function()
        CommandSage_Config.Set("preferences", "persistHistory", true)
        CommandSage_HistoryPlayback:AddToHistory("/dance")
        assert.has_no.errors(function()
            SlashCmdList["COMMANDSAGEHISTORY"]("")
        end)
    end)

    it("/searchhistory <query> prints matching lines", function()
        CommandSage_Config.Set("preferences", "persistHistory", true)
        CommandSage_HistoryPlayback:AddToHistory("/dance test")
        CommandSage_HistoryPlayback:AddToHistory("/macro foo")
        assert.has_no.errors(function()
            SlashCmdList["SEARCHHISTORY"]("dance")
        end)
    end)

    it("/clearhistory clears the table", function()
        CommandSage_Config.Set("preferences", "persistHistory", true)
        CommandSage_HistoryPlayback:AddToHistory("/dance")
        SlashCmdList["CLEARHISTORY"]("")
        local hist = CommandSage_HistoryPlayback:GetHistory()
        assert.equals(0, #hist)
    end)

    it("handles no CommandSageDB gracefully", function()
        _G.CommandSageDB = nil
        assert.has_no.errors(function()
            CommandSage_HistoryPlayback:AddToHistory("/test")
        end)
    end)

    it("AddToHistory store multiple commands in correct order", function()
        CommandSage_Config.Set("preferences", "persistHistory", true)
        CommandSage_HistoryPlayback:AddToHistory("/dance1")
        CommandSage_HistoryPlayback:AddToHistory("/dance2")
        local h = CommandSage_HistoryPlayback:GetHistory()
        assert.equals("/dance1", h[1])
        assert.equals("/dance2", h[2])
    end)

    it("GetHistory always returns same reference if not cleared", function()
        local h1 = CommandSage_HistoryPlayback:GetHistory()
        local h2 = CommandSage_HistoryPlayback:GetHistory()
        assert.equals(h1, h2)
    end)
end)
