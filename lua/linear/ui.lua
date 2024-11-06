local M = {}
local Popup = require("nui.popup")
local Input = require("nui.input")
local Issue = require("linear.models")
local api = require("linear.api")

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

	-- Build the object
	local obj = Issue:new(issueItem)

	-- Add to UI Elements
	local table_result = obj:print_result()
	vim.api.nvim_buf_set_lines(popup_main.bufnr, 0, -1, false, table_result)

	-- Updates are done differently due to them being more than 1 or nil
	vim.api.nvim_buf_set_lines(popup_main.bufnr, -1, -1, false, { "----------------------" })
	local updates = vim.tbl_get(issueItem, "data", "issue", "comments", "nodes")
	for _, value in ipairs(updates) do
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
		local issue_id = obj:get("issue_id")
		local user_data = api.fetchUserID()
		-- TODO: This returns a nested list so we grab the first item from it, hopefully people dont have multiple ids
		local user_id = vim.tbl_get(user_data, "data", "users", "nodes", 1, "id")
		local user_assigned = vim.tbl_get(user_data, "data", "users", "nodes", 1, "name")
		print(user_id, issue_id)
		local update = api.updateIssue(user_id, issue_id)
		if update ~= nil then
			print("Assigned ticket to: " .. user_assigned)
		end
	end, { noremap = true })
	-- Set the buffer in wrap mode for better readability
	vim.api.nvim_buf_set_option(popup_main.bufnr, "wrap", true)
end

function M.pickerHelp(type)
	if type == "teams" then
		return "team_id"
	end
	if type == "labels" then
		return "label_id"
	end
	if type == "projects" then
		return "project_id"
	end
end

---@param type string
function M.pickItem(type, item_list, store)
	vim.ui.select(item_list, {
		prompt = "Select " .. type .. ":",
		format_item = function(item)
			return item["name"]
		end,
	}, function(choice)
		store:set(type, choice["id"])
	end)
end

function M.getInput(key, store)
	local input = Input({
		position = "50%",
		size = {
			width = 40,
		},
		border = {
			style = "rounded",
			text = {
				top = key,
				top_align = "center",
			},
		},
		win_options = {
			winhighlight = "Normal:Normal,FloatBorder:Normal",
		},
	}, {
		prompt = "> ",
		enter = true,
		on_submit = function(value)
			store:set(key, value)
		end,
	})

	-- mount/open the component
	input:mount()
end
return M
