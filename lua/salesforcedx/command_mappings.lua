local commands = require("salesforcedx.commands")

local command_mappings = {}

command_mappings.salesforcedx_menu_items = {
	"Run Apex Method Test",
	"Run All Apex Class Tests",
	"Deploy Project to Org",
	"Generate Apex Class",
}

command_mappings.salesforcedx_commands = {
	commands.execute_test_method,
	commands.execute_test_class,
	commands.deploy_start,
	commands.generate_apex_class,
}

return command_mappings
