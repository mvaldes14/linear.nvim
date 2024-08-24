local M = {}
local Popup = require("nui.popup")

function M.showUI(issueItem, id)
	local popup = Popup({
		enter = true,
		border = {
			style = "rounded",
			text = {
				top = "Issue: " .. id,
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
	local assignee = issueItem["data"]["issue"]["assignee"]["name"]
	local project = issueItem["data"]["issue"]["project"]["name"]
	local label = issueItem["data"]["issue"]["priorityLabel"]
	local commentList = issueItem["data"]["issue"]["comments"]["nodes"]
	local comments = {}
	for _, value in ipairs(commentList) do
		table.insert(
			comments,
			{ comment = value["body"], created = value["createdAt"], username = value["user"]["name"] }
		)
	end

	local msg = string.format(
		"Issue ID: %s \n Title: %s \n State: %s \n Description: %s \n Assignee: %s \n Project:%s \n Label:%s \n Comments:%s ",
		id,
		title,
		state,
		description,
		assignee,
		project,
		label,
		comments
	)
	vim.api.nvim_buf_set_lines(popup.bufnr, -1, -1, false, { msg })
	popup:mount()
end

return M
