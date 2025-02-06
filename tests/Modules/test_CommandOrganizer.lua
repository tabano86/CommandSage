require("tests.test_helper")

describe("Module: CommandSage_CommandOrganizer", function()
    before_each(function()
        _G.CommandSageDB = {}
        CommandSage_Config:InitializeDefaults()
    end)

    it("GetCommandTags returns 'social' for /dance", function()
        local tags = CommandSage_CommandOrganizer:GetCommandTags("/dance")
        assert.is_true(#tags >= 1)
        assert.equals("social", tags[1])
    end)

    it("GetCommandTags returns empty for unknown slash", function()
        local tags = CommandSage_CommandOrganizer:GetCommandTags("/unknownslash")
        assert.equals(0, #tags)
    end)

    it("GetCategory returns the first tag or 'other'", function()
        local cat = CommandSage_CommandOrganizer:GetCategory("/dance")
        assert.equals("social", cat)
        local cat2 = CommandSage_CommandOrganizer:GetCategory("/blah")
        assert.equals("other", cat2)
    end)

    it("can add new tags dynamically if we extend tagDB manually", function()
        -- Original test accessed upvalues. We'll do a simpler approach:
        -- We'll add a public function or we just skip it:

        -- If you truly want the old approach:
        local tagDB = debug.getupvalue(CommandSage_CommandOrganizer.GetCommandTags, 1)
        assert.is_table(tagDB)
        tagDB["/mytest"] = { "testcat" }

        local cat = CommandSage_CommandOrganizer:GetCategory("/mytest")
        assert.equals("testcat", cat)

        tagDB["/mytest"] = nil -- clean up
    end)

    it("GetAllCategories returns a table of category strings", function()
        local cats = CommandSage_CommandOrganizer:GetAllCategories()
        assert.is_true(#cats >= 3)
    end)

    it("Tag for /macro is 'macros'", function()
        local cat = CommandSage_CommandOrganizer:GetCategory("/macro")
        assert.equals("macros", cat)
    end)

    it("Tag for /cmdsage is 'plugin'", function()
        local cat = CommandSage_CommandOrganizer:GetCategory("/cmdsage")
        assert.equals("plugin", cat)
    end)

    it("multiple tags can exist but only the first is returned by GetCategory", function()
        local tagDB = debug.getupvalue(CommandSage_CommandOrganizer.GetCommandTags, 1)
        local oldDanceTags = tagDB["/dance"]
        tagDB["/dance"] = { "social", "fun" }

        local cat = CommandSage_CommandOrganizer:GetCategory("/dance")
        assert.equals("social", cat)

        tagDB["/dance"] = oldDanceTags
    end)

    it("other unknown slash still returns 'other'", function()
        local cat = CommandSage_CommandOrganizer:GetCategory("/zzz")
        assert.equals("other", cat)
    end)

    it("GetAllCategories is unique set of all tags", function()
        local cats = CommandSage_CommandOrganizer:GetAllCategories()
        local uniqueSet = {}
        for _, c in ipairs(cats) do
            uniqueSet[c] = (uniqueSet[c] or 0) + 1
        end
        for _, v in pairs(uniqueSet) do
            assert.is_true(v == 1)
        end
    end)
end)
