--==========================
-- tests/test_examples.lua
--==========================
-- Just an example of a test file that doesn't rely on any CommandSage modules,
-- verifying that Busted is working.

describe("Busted sample test (test_examples.lua)", function()
    it("should run a trivial test", function()
        assert.True(1 == 1)
    end)
    it("should handle error checks", function()
        assert.has_error(function() error("Oops!") end, "Oops!")
    end)
end)
