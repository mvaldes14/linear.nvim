local M = {}
local Popup = require("nui.popup")
local Menu = require("nui.menu")
local utils = require("linear.utils")
local Issue = require("linear.models")

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

	-- Meta Object
	-- These are the paths returned by the API, using tbl_get prevents an invalid lookup
	local issue = {
		title = vim.tbl_get(issueItem, "data", "issue", "title"),
		assignee = vim.tbl_get(issueItem, "data", "issue", "assignee", "name"),
		state = vim.tbl_get(issueItem, "data", "issue", "state", "name"),
		project = vim.tbl_get(issueItem, "data", "issue", "project", "name"),
		label = vim.tbl_get(issueItem, "data", "issue", "priorityLabel"),
		description = vim.tbl_get(issueItem, "data", "issue", "description"),
		updates = vim.tbl_get(issueItem, "data", "issue", "comments", "nodes"),
	}

	-- Build the object
	local obj = Issue:new(issue)
	local table_result = Issue.print(obj)
	-- Add to UI Elements
	for _, value in ipairs(table_result) do
		vim.api.nvim_buf_set_lines(popup_main.bufnr, -1, -1, false, { value })
	end
	--
	-- -- Updates are done differently due to them being more than 1
	vim.api.nvim_buf_set_lines(popup_main.bufnr, -1, -1, false, { "Updates: " })
	for _, value in ipairs(issue["updates"]) do
		local update = vim.split(value["body"], "\n")
		vim.api.nvim_buf_set_lines(popup_main.bufnr, -1, -1, false, { "Username: " .. value["user"]["name"] })
		vim.api.nvim_buf_set_lines(popup_main.bufnr, -1, -1, false, { "Created: " .. value["createdAt"] })
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
