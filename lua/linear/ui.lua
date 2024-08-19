local popup = require("plenary.popup")
local M = {}

function M.createUI()
	local bufnr = vim.api.nvim_create_buf(false, false)
	local width = 60
	local height = 10
	local id, win = popup.create(bufnr, {
		title = "Linear",
		line = math.floor(((vim.o.lines - height) / 2) - 1),
		col = math.floor((vim.o.columns - width) / 2),
		minwidth = width,
		minheight = height,
		borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
	})
	return {
		id = id,
		win = win,
	}
end

M.ui = M.createUI()
