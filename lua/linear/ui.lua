local M = {}
local Popup = require("nui.popup")
local Layout = require("nui.layout")
local Menu = require("nui.menu")
local utils = require("linear.utils")

---@param issueItem issueItem
---@param id string
function M.showIssue(issueItem, id)
	local popup_main = Popup({
		border = {
			style = "rounded",
			text = {
				top = "Issue: " .. id,
				top_align = "center",
			},
		},
		position = "50%",
		size = {
			width = "40%",
			height = "30%",
		},
	})

	local popup_comments = Popup({
		enter = true,
		focusable = true,
		border = {
			style = "rounded",
			text = {
				top = "Updates",
				top_align = "center",
			},
		},
		position = "50%",
		size = {
			width = "40%",
			height = "80%",
		},
	})

	local layout = Layout(
		{
			position = "50%",
			size = {
				width = 80,
				height = "80%",
			},
		},
		Layout.Box({
			Layout.Box(popup_main, { size = "40%" }),
			Layout.Box(popup_comments, { size = "60%" }),
		}, { dir = "row" })
	)

	local title = issueItem["data"]["issue"]["title"]
	local description = issueItem["data"]["issue"]["description"]
	local state = issueItem["data"]["issue"]["state"]["name"]
	local assignee = issueItem["data"]["issue"]["assignee"]["name"]
	local project = issueItem["data"]["issue"]["project"]["name"]
	local label = issueItem["data"]["issue"]["priorityLabel"]
	local comment_list = issueItem["data"]["issue"]["comments"]["nodes"]
	local comments = {}
	for _, value in ipairs(comment_list) do
		table.insert(
			comments,
			{ comment = value["body"], created = value["createdAt"], username = value["user"]["name"] }
		)
	end

	local item_info = {
		"Title: " .. title,
		"State: " .. state,
		"Description: " .. description,
		"Asignee: " .. assignee,
		"Project: " .. project,
		"Label: " .. label,
	}
	for _, value in ipairs(item_info) do
		vim.api.nvim_buf_set_lines(popup_main.bufnr, -1, -1, false, { value })
	end
	for _, value in ipairs(comments) do
		local update = vim.split(value["comment"], "\n")
		vim.api.nvim_buf_set_lines(popup_comments.bufnr, -1, -1, false, { "Username: " .. value["username"] })
		vim.api.nvim_buf_set_lines(popup_comments.bufnr, -1, -1, false, { "Created: " .. value["created"] })
		for _, comment in ipairs(update) do
			vim.api.nvim_buf_set_lines(popup_comments.bufnr, -1, -1, false, { comment })
		end
		vim.api.nvim_buf_set_lines(popup_comments.bufnr, -1, -1, false, { "----------------------" })
	end

	layout:update(Layout.Box({
		Layout.Box(popup_main, { size = "30%" }),
		Layout.Box(popup_comments, { size = "70%" }),
	}, { dir = "col" }))

	layout:mount()
	popup_comments:map("n", "<esc>", function()
		layout:unmount()
	end, { noremap = true })
end

---@param item_list table
---@param type string
function M.pickItem(item_list, type)
	local menu_list = {}
	for _, value in ipairs(item_list) do
		table.insert(menu_list, Menu.item(value[2]))
	end
	local menu = Menu({
		position = "50%",
		size = {
			width = 25,
			height = 5,
		},
		border = {
			style = "single",
			text = {
				top = "Choose: " .. type,
				top_align = "center",
			},
		},
		win_options = {
			winhighlight = "Normal:Normal,FloatBorder:Normal",
		},
	}, {
		lines = menu_list,
		max_width = 20,
		keymap = {
			focus_next = { "j", "<Down>", "<Tab>" },
			focus_prev = { "k", "<Up>", "<S-Tab>" },
			close = { "<Esc>", "<C-c>" },
			submit = { "<CR>", "<Space>" },
		},
		on_submit = function(item)
			utils.state(item)
		end,
	})

	-- mount the component
	menu:mount()
end
return M
