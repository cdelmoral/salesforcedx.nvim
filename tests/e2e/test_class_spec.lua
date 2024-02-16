local stub = require("luassert.stub")
local match = require("luassert.match")

local create_buffer_with_content = function(input)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_win_set_buf(0, buf)
	vim.api.nvim_buf_set_lines(0, 0, -1, true, vim.split(input, "\n"))
	return buf
end

local test_class = [[
@IsTest
public class MyTest {
  @IsTest
  static void myTestMethod1() {
    Assert.isTrue(true);
  }
}
]]

describe("execute_test_class", function()
	local sf = require("sf")

	before_each(function()
		create_buffer_with_content(test_class)
		vim.cmd("set filetype=apex")
	end)

	it("runs test class", function()
		stub(vim.fn, "jobstart")

		vim.api.nvim_win_set_cursor(0, { 4, 1 })
		sf.execute_test_class()

		assert.stub(vim.fn.jobstart).was_called()
		local expected_command = "sf apex run test --class-names MyTest --wait 15"
		assert.stub(vim.fn.jobstart).was_called_with(vim.split(expected_command, " "), match._)
	end)
end)
