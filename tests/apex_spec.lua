local create_buffer_with_content = function(input)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_win_set_buf(0, buf)
	vim.api.nvim_buf_set_lines(0, 0, -1, true, vim.split(input, "\n"))
	return buf
end

local VALID_TEST_CLASS_CONTENT = [[
@IsTest
public class MyTest {
  @IsTest
  static void myTestMethod1() {
    Assert.isTrue(true);
  }
}
]]

describe("apex", function()
	local apex = require("salesforcedx.apex")

	describe("valid apex test class", function()
		local bufnr

		before_each(function()
			bufnr = create_buffer_with_content(VALID_TEST_CLASS_CONTENT)
			vim.cmd("set filetype=apex")
		end)

		it("gets class declaration node", function()
			local node = vim.treesitter.get_node({ bufnr = bufnr, pos = { 4, 0 } })
			local class_node = apex.get_class_declaration_node(node)
			assert.are.same("class_declaration", class_node:type())
		end)

		it("gets method declaraion node", function()
			local node = vim.treesitter.get_node({ bufnr = bufnr, pos = { 4, 0 } })
			local method_node = apex.get_current_method_declaration_node(node)
			assert.are.same("method_declaration", method_node:type())
		end)
	end)
end)
