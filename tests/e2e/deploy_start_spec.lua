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

describe("deploy_start", function()
	local sf = require("salesforcedx")

	before_each(function()
		create_buffer_with_content(test_class)
		vim.cmd("set filetype=apex")
	end)

	it("runs project deploy start command", function()
		stub(vim.fn, "jobstart")

		sf.deploy_start()

		assert.stub(vim.fn.jobstart).was_called()
		local expected_command = "sf project deploy start"
		assert.stub(vim.fn.jobstart).was_called_with(vim.split(expected_command, " "), match._)
	end)
end)
