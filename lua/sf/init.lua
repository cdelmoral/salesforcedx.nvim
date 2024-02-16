local ts_utils = require("nvim-treesitter.ts_utils")
local apex = require("sf.apex")
local utils = require("sf.utils")
local salesforce = require("sf.salesforce")

M = {}

M.execute_test_class = function()
	local current_node = ts_utils.get_node_at_cursor()

	if not current_node then
		vim.api.nvim_err_writeln("Not an apex test class")
		return
	end

	local class_node = apex.get_class_declaration_node(current_node)
	if not apex.is_test(class_node) then
		vim.api.nvim_err_writeln("Not an apex test class")
		return
	end
	local class_name = apex.get_identifier_name(class_node)

	local test_command = salesforce.get_apex_run_test(class_name)
	local bufnr = utils.create_split()
	utils.execute_command(test_command, bufnr)
end

M.execute_test_method = function()
	local current_node = ts_utils.get_node_at_cursor()

	if not current_node then
		vim.api.nvim_err_writeln("Not an apex test class")
		return
	end

	local class_node = apex.get_class_declaration_node(current_node)
	if not apex.is_test(class_node) then
		vim.api.nvim_err_writeln("Not an apex test class")
		return
	end
	local class_name = apex.get_identifier_name(class_node)

	local method_node = apex.get_current_method_declaration_node(current_node)
	if method_node == nil or not apex.is_test(method_node) then
		vim.api.nvim_err_writeln("Not an apex test method")
		return
	end
	local method_name = apex.get_identifier_name(method_node)

	local test_command = salesforce.get_apex_run_test(class_name, method_name)
	local bufnr = utils.create_split()
	utils.execute_command(test_command, bufnr)
end

M.setup = function()
	vim.api.nvim_command("command! TestMethod lua require'sf'.execute_test_method()<CR>")
	vim.api.nvim_command("command! TestClass lua require'sf'.execute_test_class()<CR>")
end

return M
