local utils = require("salesforcedx.utils")
local command_mappings = require("salesforcedx.command_mappings")
local salesforce = require("salesforcedx.salesforce")

local function show_menu_callback(selection)
	if selection == nil then
		return
	end

	local command
	for index, menu_item in ipairs(command_mappings.salesforcedx_menu_items) do
		if menu_item == selection then
			command = command_mappings.salesforcedx_commands[index]
		end
	end

	if command ~= nil then
		command()
	end
end

M = {}

function M.show_menu()
	utils.show_menu({
		title = "Salesforce Commands",
		menu_items = command_mappings.salesforcedx_menu_items,
		callback = show_menu_callback,
	})
end

function M.get_default_target_org()
	return salesforce.get_default_target_org()
end

M.setup = function()
	vim.api.nvim_command("command! SalesforceDX lua require'salesforcedx'.show_menu()<CR>")
end

return M
