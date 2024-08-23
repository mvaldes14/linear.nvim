-- Query the Linear API to fetch issues
local M = {}
local LINEAR_API_URL = "https://api.linear.app/graphql"
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local sorters = require("telescope.sorters")
local utils = require("linear.utils")

---@alias issueList {branch: string, title: string, status: string}[]
---@param apiKey string
---@return issueList
function M.fetchIssues(apiKey)
	local issueList = {}
	local payload = '{"query": "{ issues { nodes { title state {name} branchName identifier } } }" }'
	local request = utils.makeRequest(apiKey, LINEAR_API_URL, payload)
	for _, value in ipairs(request["data"]["issues"]["nodes"]) do
		local title = value["title"]
		local status = value["state"]["name"]
		local branch = value["branchName"]
		local id = value["identifier"]
		local issue = { branch = branch, title = title, status = status, id = id }
		table.insert(issueList, issue)
	end
	return issueList
end

---@param issueID string
---@param apiKey string
---@alias issueItem {title: string, status: string, description: string}
---@return issueItem
--'{"query":"query Issue {  issue(id: \"TW-37\") {    title state { name }  description  assignee { name } project { name }  priorityLabel  comments {  nodes {  body  createdAt  user {  name }  } } }}"}'
local function fetchSingleIssue(apiKey, issueID)
	local query = [[{"query":"query Issue { issue(id: "TW-1") { title state { name } description }}"}]]
	local encoded_query = string.gsub(query, '"', '\\"')
	local request = utils.makeRequest(apiKey, LINEAR_API_URL, encoded_query)
	return request
end

---@param apiKey string
---@return string
local function getTeamID(apiKey)
	local query = '{"query":"query Teams { teams { nodes { id name } }}"}'
	local request = utils.makeRequest(apiKey, LINEAR_API_URL, query)
	return request["data"]["teams"]["nodes"]["id"]
end

function M.createIssue(apiKey, title, description)
	local teamID = getTeamID(apiKey)
	local query = string.format(
		[[{"query":"mutation CreateIssue { createIssue(input: {title: "%s", description: "%s", teamId: "%s"}) { issue { id } } }"}]],
		title,
		description,
		teamID
	)
	local encoded_query = string.gsub(query, '"', '\\"')
	local request = utils.makeRequest(apiKey, LINEAR_API_URL, encoded_query)
	if not request["data"]["issueCreate"]["success"] then
		print("Issue not created")
	end
end

---@param issueList issueList
---@resturn nil
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
			attach_mappings = function(prompt_bufnr, _)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					local issue = fetchSingleIssue(utils.getKey(), selection.value.id)
					print(issue)
				end)
				return true
			end,
		})
		:find()
end

return M
