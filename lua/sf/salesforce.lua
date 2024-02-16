local salesforce = {}

function salesforce.get_apex_run_test(class_name, method_name)
	local class_method_name = string.format("%s.%s", class_name, method_name)
	return { "sf", "apex", "run", "test", "--tests", class_method_name, "--wait", "15" }
end

return salesforce
