-- Query the Linear API to fetch issues
local M = {}
local curl = require("plenary.curl")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local sorters = require("telescope.sorters")
local conf = require("linear.config")

---@alias issueList {branch: string, title: string, status: string}[]
---@param apiKey string
---@return issueList
function M.fetchIssues(apiKey)
	local issueList = {}
	local request = curl.post(conf.defaults.linear_url, {
		headers = {
			["Content-Type"] = "application/json",
			["Authorization"] = apiKey,
		},
		body = conf.defaults.issues_query,
	})
	if request.status ~= 200 then
		error("Failed to fetch issues")
	end
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
