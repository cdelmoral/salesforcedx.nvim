local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local prompt = require("salesforcedx.prompt")
local notification = require("salesforcedx.notification")

local utils = {}

function utils.create_split()
	vim.cmd("split")
	local win = vim.api.nvim_get_current_win()
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_win_set_buf(win, bufnr)
	return bufnr
end

function utils.append_to_buffer_cb(bufnr)
	return function(data)
		vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, data)
	end
end

function utils.execute_command(command, on_stdout, on_stderr, on_exit)
	vim.fn.jobstart(command, {
		stdout_buffered = true,
		stderr_buffered = true,
		on_stdout = function(_, data)
			if data then
				on_stdout(data)
			end
		end,
		on_stderr = function(_, data)
			if data then
				on_stderr(data)
			end
		end,
		on_exit = on_exit,
	})
end

function utils.execute_command_progress(command, cb)
	local out = { {}, {} }
	utils.execute_command(command, function(data)
		table.insert(out[1], data)
	end, function(data)
		table.insert(out[2], data)
	end, function()
		cb(out)
	end)
end

function utils.execute_command_buffer(command, bufnr)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { table.concat(command, " "), "" })
	vim.api.nvim_win_set_cursor(0, { 2, 1 })
	local cb = utils.append_to_buffer_cb(bufnr)
	utils.execute_command(command, cb, cb)
end

function utils.show_prompt(opts)
	prompt.new_prompt(opts.title, opts.size.width, opts.callback)
end

function utils.show_menu(opts)
	local size = opts.size or { height = 10, width = 40 }

	pickers
		.new({}, {
			layout_strategy = "center",
			layout_config = size,
			prompt_title = opts.title,
			finder = finders.new_table({
				results = opts.menu_items,
			}),
			previewer = nil,
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					opts.callback(selection.display)
				end)

				return true
			end,
		})
		:find()
end

function utils.split_string(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		table.insert(t, str)
	end
	return t
end

function utils.find_subdirectories(directories)
	local command_parts = { "find" }
	for _, dir in ipairs(directories) do
		table.insert(command_parts, dir.path)
	end
	table.insert(command_parts, "-mindepth")
	table.insert(command_parts, "1")
	table.insert(command_parts, "-type")
	table.insert(command_parts, "d")
	local command = table.concat(command_parts, " ")
	return utils.split_string(vim.fn.system(command), "\n")
end

return utils
