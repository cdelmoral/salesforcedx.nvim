local salesforce = {}

function salesforce:new(opts)
	local o = {}
	setmetatable(o, self)
	self.__index = self

	opts = opts or {}
	self.json = opts.json == nil or opts.json
	self.commands = { "sf" }
	self.options = {}

	return o
end

function salesforce:build()
	local command_with_options = {}

	for _, command in ipairs(self.commands) do
		table.insert(command_with_options, command)
	end

	for _, option in ipairs(self.options) do
		if type(option) == "string" then
			table.insert(command_with_options, option)
		else
			for _, opt in ipairs(option) do
				table.insert(command_with_options, opt)
			end
		end
	end

	if self.json then
		table.insert(command_with_options, "--json")
	end

	return command_with_options
end

function salesforce:project()
	table.insert(self.commands, "project")
	return self
end

function salesforce:deploy()
	table.insert(self.commands, "deploy")
	return self
end

function salesforce:start()
	table.insert(self.commands, "start")
	return self
end

function salesforce:apex()
	table.insert(self.commands, "apex")
	return self
end

function salesforce:generate()
	table.insert(self.commands, "generate")
	return self
end

function salesforce:class(opts)
	table.insert(self.commands, "class")
	table.insert(self.options, { "--output-dir", opts.output_directory })
	table.insert(self.options, { "--name", opts.name })
	return self
end

function salesforce.is_salesforce_project_directory()
	local sfdx_project_file = vim.fn.getcwd() .. "/sfdx-project.json"

	return vim.fn.filereadable(sfdx_project_file) == 1
end

function salesforce.get_default_target_org()
	if not salesforce.is_salesforce_project_directory() then
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

function salesforce.get_apex_run_test(class_name, method_name)
	local command = { "sf", "apex", "run", "test" }

	if method_name ~= nil then
		local class_method_name = string.format("%s.%s", class_name, method_name)
		table.insert(command, "--tests")
		table.insert(command, class_method_name)
	else
		table.insert(command, "--class-names")
		table.insert(command, class_name)
	end

	table.insert(command, "--wait")
	table.insert(command, "15")
	return command
end

function salesforce.get_sfdx_project_directories()
	local cwd = vim.fn.getcwd()
	local sfdx_project_file = cwd .. "/sfdx-project.json"
	if vim.fn.filereadable(sfdx_project_file) == 1 then
		local file = io.open(sfdx_project_file, "r")
		if not file then
			return {}
		end

		local content = file:read("*all")
		file:close()
		local package_directories = vim.json.decode(content)["packageDirectories"]
		return package_directories
	end
	return {}
end

function salesforce.parse_result(out)
	local response = vim.json.decode(table.concat(out[1][1], "\n"))
	local result = { success = false, message = "" }
	if response.status ~= 0 then
		result.success = false
		result.message = response.message
	else
		result.success = true
		result.message = response.result.status
	end
	return result
end

return salesforce
