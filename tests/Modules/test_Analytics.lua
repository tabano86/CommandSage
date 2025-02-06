require("tests.test_helper")

describe("Module: CommandSage_Analytics", function()

    before_each(function()
        _G.CommandSageDB = {}
        CommandSage_Config:InitializeDefaults()
    end)

    it("AddFavorite marks slash as favorite", function()
        CommandSage_Analytics:AddFavorite("/dance")
        assert.is_true(CommandSage_Analytics:IsFavorite("/dance"))
    end)

    it("RemoveFavorite unmarks slash as favorite", function()
        CommandSage_Analytics:AddFavorite("/dance")
        CommandSage_Analytics:RemoveFavorite("/dance")
        -- Make sure we return a boolean false instead of nil:
        assert.is_false(CommandSage_Analytics:IsFavorite("/dance"))
    end)

    it("Blacklist command sets it blacklisted", function()
        CommandSage_Analytics:Blacklist("/macro")
        assert.is_true(CommandSage_Analytics:IsBlacklisted("/macro"))
    end)

    it("Unblacklist command sets it not blacklisted", function()
        CommandSage_Analytics:Blacklist("/macro")
        CommandSage_Analytics:Unblacklist("/macro")
        assert.is_false(CommandSage_Analytics:IsBlacklisted("/macro"))
    end)

    it("ListFavorites returns a table of slash commands", function()
        CommandSage_Analytics:AddFavorite("/dance")
        CommandSage_Analytics:AddFavorite("/macro")
        local favs = CommandSage_Analytics:ListFavorites()
        assert.is_true(#favs >= 2)
    end)

    it("initially no analytics table is present", function()
        assert.is_nil(_G.CommandSageDB.analytics)
        local black = CommandSage_Analytics:IsBlacklisted("/something")
        assert.is_false(black)
        assert.is_table(_G.CommandSageDB.analytics)
    end)

    it("RemoveFavorite on non-favorite is safe", function()
        CommandSage_Analytics:RemoveFavorite("/test")
        assert.is_false(CommandSage_Analytics:IsFavorite("/test"))
    end)

    it("Unblacklist on non-blacklisted is safe", function()
        CommandSage_Analytics:Unblacklist("/test")
        assert.is_false(CommandSage_Analytics:IsBlacklisted("/test"))
    end)

    it("favorites and blacklisted are distinct sets", function()
        CommandSage_Analytics:AddFavorite("/dance")
        CommandSage_Analytics:Blacklist("/dance")
        assert.is_true(CommandSage_Analytics:IsBlacklisted("/dance"))
        assert.is_true(CommandSage_Analytics:IsFavorite("/dance"))
        -- They can coexist in this design
    end)

    it("handles no CommandSageDB gracefully", function()
        _G.CommandSageDB = nil
        assert.has_no.errors(function()
            CommandSage_Analytics:AddFavorite("/dance")
        end)
    end)
end)
