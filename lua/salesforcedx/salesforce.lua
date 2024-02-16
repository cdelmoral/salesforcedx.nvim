local salesforce = {}

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

function salesforce.get_project_deploy_start()
	return { "sf", "project", "deploy", "start" }
end

return salesforce
