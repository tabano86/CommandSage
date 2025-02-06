-- tests/test_examples.lua
describe("Busted sample test (test_examples.lua)", function()
    it("should run a trivial test", function()
        assert.True(1 == 1)
    end)
    it("should handle error checks", function()
        assert.has_error(function() error("Oops!") end, "Oops!")
    end)
end)
