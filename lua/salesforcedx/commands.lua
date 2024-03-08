local salesforce = require("salesforcedx.salesforce")
local ts_utils = require("nvim-treesitter.ts_utils")
local apex = require("salesforcedx.apex")
local utils = require("salesforcedx.utils")
local job_queue = require("salesforcedx.job_queue")
local notification = require("salesforcedx.notification")

local commands = {}

function commands.execute_test_class()
	if not salesforce.is_salesforce_project_directory() then
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
	utils.execute_command_buffer(test_command, bufnr)
end

function commands.execute_test_method()
	if not salesforce.is_salesforce_project_directory() then
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
	utils.execute_command_buffer(test_command, bufnr)
end

function commands.deploy_start()
	if not salesforce.is_salesforce_project_directory() then
		vim.api.nvim_err_writeln("Not an sfdx project")
		return
	end

	local command = salesforce:new():project():deploy():start():build()

	local n = notification:new({ message = "Deploying changes..." })
	n:start_progress()
	utils.execute_command_progress(command, function(out)
		local result = salesforce.parse_result(out)
		local opts = {
			message = result.message,
			level = result.success and vim.log.levels.INFO or vim.log.levels.ERROR,
		}
		n:complete(opts)
	end)
end

function commands.generate_apex_class()
	local sfdx_project_directories = salesforce.get_sfdx_project_directories()
	local directories = utils.find_subdirectories(sfdx_project_directories)

	local jobs = job_queue:new()

	jobs:add(utils.show_menu, {
		title = "Choose Target Directory",
		menu_items = directories,
		size = { height = 20, width = 80 },
	})

	jobs:add(utils.show_prompt, {
		title = "Apex Class Name",
		size = { width = 50 },
	})

	jobs:on_complete(function(results)
		local command = salesforce
			:new()
			:apex()
			:generate()
			:class({
				output_directory = results[1],
				name = results[2],
			})
			:build()
		local n = notification:new({ message = "Creating apex class..." })
		n:start_progress()
		utils.execute_command_progress(command, function(out)
			local result = salesforce.parse_result(out)
			local opts = {
				message = "Apex class successfully created",
				level = result.success and vim.log.levels.INFO or vim.log.levels.ERROR,
			}
			n:complete(opts)
			vim.cmd("e " .. results[1] .. "/" .. results[2] .. ".cls")
		end)
	end)

	jobs:start()
end

return commands
