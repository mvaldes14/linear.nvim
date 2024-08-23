local M = {}
local Popup = require("nui.popup")

function M.showUI(issueItem, id)
	local popup = Popup({
		enter = true,
		border = {
			style = "rounded",
			text = {
				top = "Issue" .. id,
				top_align = "center",
			},
		},
		focusable = true,
		position = "50%",
		size = {
			width = "40%",
			height = "40%",
		},
	})

	local title = issueItem["data"]["issue"]["title"]
	local description = issueItem["data"]["issue"]["description"]
	local state = issueItem["data"]["issue"]["state"]["name"]
	local msg = string.format("ID: %s, Title: %s,  State: %s,  Description: %s", id, title, description, state)
	vim.api.nvim_buf_set_lines(popup.bufnr, -1, -1, false, { msg })
	popup:mount()
end

return M
