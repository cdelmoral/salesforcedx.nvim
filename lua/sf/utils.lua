local utils = {}

function utils.create_split()
	vim.cmd("split")
	local win = vim.api.nvim_get_current_win()
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_win_set_buf(win, bufnr)
	return bufnr
end

function utils.execute_command(command, bufnr)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { table.concat(command, " "), "" })
	vim.api.nvim_win_set_cursor(0, { 2, 1 })
	vim.fn.jobstart(command, {
		stdout_buffered = true,
		stderr_buffered = true,
		on_stdout = function(_, data)
			if data then
				vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, data)
			end
		end,
		on_stderr = function(_, data)
			if data then
				vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, data)
			end
		end,
	})
end

return utils
