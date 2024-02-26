local popup = require("plenary.popup")

local prompt_char = " "

local prompt = {}

function prompt.execute_callback()
	local input = vim.api.nvim_buf_get_lines(prompt.bufnr, 0, -1, false)
	local callback = prompt.callback
	prompt.close_prompt()
	local clean_input = string.gsub(input[1], "^" .. prompt_char, "", 1)
	callback(clean_input)
end

function prompt.new_prompt(title, size, callback)
	-- Close the prompt if it is already open
	prompt.close_prompt()

	local height = 1
	local width = size
	local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }

	prompt.callback = callback
	prompt.bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_option(prompt.bufnr, "buftype", "prompt")
	prompt.win_id = popup.create(prompt.bufnr, {
		title = title,
		minwidth = width,
		minheight = height,
		borderchars = borderchars,
		titlehighlight = "TelescopeTitle",
		borderhighlight = "TelescopeBorder",
		highlight = "TelescopeNormal",
	})

	-- TODO: Esto no functiona
	-- Igual para simplicar no permitir normal mode
	-- Figure out unsaved buffer when exiting

	-- vim.api.nvim_create_autocmd("BufLeave", {
	-- 	buffer = prompt.bufnr,
	-- 	once = true,
	-- 	callback = function()
	-- 		prompt.close_prompt()
	-- 		pcall(vim.api.nvim_win_close, prompt.win_id, true)
	-- 	end,
	-- })

	local close_prompt_command = "<cmd>lua require('salesforcedx.prompt').close_prompt()<CR>"
	vim.api.nvim_buf_set_keymap(prompt.bufnr, "n", "q", close_prompt_command, { noremap = true, silent = true })
	vim.api.nvim_buf_set_keymap(prompt.bufnr, "n", "<ESC>", close_prompt_command, { noremap = true, silent = true })
	local execute_callback_command = "<cmd>lua require('salesforcedx.prompt').execute_callback()<CR>"
	vim.api.nvim_buf_set_keymap(prompt.bufnr, "i", "<CR>", execute_callback_command, { noremap = true, silent = true })
	vim.fn.prompt_setprompt(prompt.bufnr, prompt_char)
	vim.fn.prompt_setcallback(prompt.bufnr, prompt.execute_callback)

	vim.api.nvim_command("startinsert!")
end

function prompt.close_prompt()
	if prompt.win_id and vim.api.nvim_win_is_valid(prompt.win_id) then
		vim.api.nvim_win_close(prompt.win_id, true)
	end

	prompt.win_id = nil
	prompt.bufnr = nil
	prompt.callback = nil
end

return prompt
