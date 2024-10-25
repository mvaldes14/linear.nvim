local M = {}
local Popup = require("nui.popup")
local Menu = require("nui.menu")
local utils = require("linear.utils")
local issue = require("linear.models")

---@param issueItem issueItem
---@param id string
function M.showIssue(issueItem, id)
	local popup_main = Popup({
		border = {
			style = "rounded",
			text = {
				top = id,
				top_align = "center",
				bottom = "<esc> close, <G> switch to branch, <A> assign to self",
				bottom_allign = "center",
			},
		},
		position = "50%",
		size = {
			width = "80%",
			height = "40%",
		},
		enter = true,
		focusable = true,
		buf_options = {
			readonly = true,
		},
	})

	local title = issueItem["data"]["issue"]["title"]
	local description = issueItem["data"]["issue"]["description"]
	local state = issueItem["data"]["issue"]["state"]["name"]
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
	local issueObject = {
		Title = title,
		State = state,
		Project = project,
		Label = label,
	}

	-- Build the object
	local obj = issue.create(issueObject)
	local descriptionList = issue.description(description)
	-- Add to UI Elements
	for key, value in pairs(obj) do
		vim.api.nvim_buf_set_lines(popup_main.bufnr, -1, -1, false, { key .. ": " .. value })
	end

	vim.api.nvim_buf_set_lines(popup_main.bufnr, -1, -1, false, { "Description: " })
	for _, value in ipairs(descriptionList) do
		vim.api.nvim_buf_set_lines(popup_main.bufnr, -1, -1, false, value)
	end

	vim.api.nvim_buf_set_lines(popup_main.bufnr, -1, -1, false, { "----------------------" })
	vim.api.nvim_buf_set_lines(popup_main.bufnr, -1, -1, false, { "Updates: " })
	for _, value in ipairs(comments) do
		local update = vim.split(value["comment"], "\n")
		vim.api.nvim_buf_set_lines(popup_main.bufnr, -1, -1, false, { "Username: " .. value["username"] })
		vim.api.nvim_buf_set_lines(popup_main.bufnr, -1, -1, false, { "Created: " .. value["created"] })
		for _, comment in ipairs(update) do
			vim.api.nvim_buf_set_lines(popup_main.bufnr, -1, -1, false, { comment })
		end
		vim.api.nvim_buf_set_lines(popup_main.bufnr, -1, -1, false, { "----------------------" })
	end

	-- Show Elements
	popup_main:mount()
	popup_main:map("n", "<esc>", function()
		popup_main:unmount()
	end, { noremap = true })
	popup_main:map("n", "G", function()
		vim.cmd("!git checkout -b " .. id)
	end, { noremap = true })
	popup_main:map("n", "A", function()
		-- TODO: For branch TW-52
		print("Pending")
	end, { noremap = true })
	-- Set the buffer in wrap mode for better readability
	vim.api.nvim_buf_set_option(popup_main.bufnr, "wrap", true)
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
