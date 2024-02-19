local ts_utils = require("nvim-treesitter.ts_utils")
local apex = require("salesforcedx.apex")
local utils = require("salesforcedx.utils")
local salesforce = require("salesforcedx.salesforce")

M = {}

M.is_salesforce_project_directory = function()
	local sfdx_project_file = vim.fn.getcwd() .. "/sfdx-project.json"

	return vim.fn.filereadable(sfdx_project_file) == 1
end

M.execute_test_class = function()
	if not M.is_salesforce_project_directory() then
		vim.api.nvim_err_writeln("Not an sfdx project")
		return
	end

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
	if not M.is_salesforce_project_directory() then
		vim.api.nvim_err_writeln("Not an sfdx project")
		return
	end

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

M.deploy_start = function()
	if not M.is_salesforce_project_directory() then
		vim.api.nvim_err_writeln("Not an sfdx project")
		return
	end

	local command = salesforce.get_project_deploy_start()
	local bufnr = utils.create_split()
	utils.execute_command(command, bufnr)
end

M.get_default_target_org = function()
	if not M.is_salesforce_project_directory() then
		return ""
	end

	local sf_config = vim.fn.getcwd() .. "/.sf/config.json"
	if vim.fn.filereadable(sf_config) == 1 then
		local file = io.open(sf_config, "r")
		if not file then
			return ""
		end

		local content = file:read("*all")
		file:close()
		local default_target_org = vim.json.decode(content)["target-org"]
		return default_target_org
	end

	return ""
end

M.setup = function()
	vim.api.nvim_command("command! TestMethod lua require'salesforcedx'.execute_test_method()<CR>")
	vim.api.nvim_command("command! TestClass lua require'salesforcedx'.execute_test_class()<CR>")
	vim.api.nvim_command("command! Deploy lua require'salesforcedx'.deploy_start()<CR>")
end

return M
