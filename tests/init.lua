local M = {}

function M.root(root)
	local f = debug.getinfo(1, "S").source:sub(2)
	return vim.fn.fnamemodify(f, ":p:h:h") .. "/" .. (root or "")
end

function M.load(plugin)
	local name = plugin:match(".*/(.*)")
	local package_root = M.root(".tests/site/pack/deps/start/")
	if not vim.loop.fs_stat(package_root .. name) then
		print("Installing " .. plugin)
		vim.fn.mkdir(package_root, "p")
		vim.fn.system({
			"git",
			"clone",
			"--depth=1",
			"https://github.com/" .. plugin .. ".git",
			package_root .. "/" .. name,
		})
	end
end

function M.setup()
	vim.cmd([[set runtimepath=$VIMRUNTIME]])
	vim.opt.runtimepath:append(M.root("tests/site/pack/deps/start/nvim-treesitter/parser"))
	vim.opt.runtimepath:append(M.root())
	vim.opt.packpath = { M.root(".tests/site") }

	M.load("nvim-treesitter/nvim-treesitter")
	M.load("nvim-lua/plenary.nvim")

	require("nvim-treesitter.configs").setup({
		ensure_installed = { "apex" },
		sync_install = true,
	})
end

M.setup()
