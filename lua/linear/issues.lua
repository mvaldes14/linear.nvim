-- Query the Linear API to fetch issues
local M = {}
local curl = require("plenary.curl")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local sorters = require("telescope.sorters")
local conf = require("linear.config")

---@return boolean
function M.validateKey()
	local linearAPI = conf.defaults.linear_api
	if linearAPI == nil then
		print("Linear API Token Not Found")
		return false
	end
	return true
end

---@alias issueList {branch: string, title: string, status: string}[]
---@return issueList
function M.fetchIssues()
	local issueList = {}
	local request = curl.post(conf.defaults.linear_url, {
		headers = {
			["Content-Type"] = "application/json",
			["Authorization"] = conf.defaults.linear_api,
		},
		body = conf.defaults.issues_query,
	})
	-- Decode into json and grab the fields
	local payload = vim.json.decode(request.body)
	for _, value in ipairs(payload["data"]["issues"]["nodes"]) do
		local title = value["title"]
		local status = value["state"]["name"]
		local branch = value["branchName"]
		local issue = { branch = branch, title = title, status = status }
		table.insert(issueList, issue)
	end
	return issueList
end

---@param issueList issueList
function M.pickIssue(issueList)
	pickers
		.new({}, {
			prompt_title = "Issues",
			finder = finders.new_table({
				results = issueList,
				entry_maker = function(entry)
					return {
						value = entry,
						display = "[" .. entry.branch .. "] " .. entry.title .. " (" .. entry.status .. ")",
						ordinal = "[" .. entry.branch .. "] " .. entry.title .. " (" .. entry.status .. ")",
					}
				end,
			}),
			sorter = sorters.get_generic_fuzzy_sorter(),
		})
		:find()
end

return M
