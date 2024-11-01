-- Query the Linear API to fetch issues
local M = {}
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local sorters = require("telescope.sorters")
local utils = require("linear.utils")
local ui = require("linear.ui")
local api = require("linear.api")
local LINEAR_API_URL = "https://api.linear.app/graphql"

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
local function fetchSingleIssue(apiKey, issueID)
	local payload = {
		query = string.format(
			'query Issue { issue(id: "%s") { id title state { name } description assignee {id name} project {name} priorityLabel comments {nodes {body createdAt user{name}}}}}',
			issueID
		),
	}
	local request = utils.makeRequest(apiKey, LINEAR_API_URL, vim.json.encode(payload))
	return request
end

---@param apiKey string
---@return table
local function getTeamID(apiKey)
	local teams = {}
	local query = '{"query":"query Teams { teams { nodes { id name } }}"}'
	local request = utils.makeRequest(apiKey, LINEAR_API_URL, query)
	for _, value in ipairs(request["data"]["teams"]["nodes"]) do
		table.insert(teams, { value["id"], value["name"] })
	end
	return teams
end

---@param apiKey string
---@return table
local function getLabelID(apiKey)
	local labels = {}
	local query = '{"query":"query{ issueLabels {  nodes {  id  name }  }}"}'
	local encoded_query = string.gsub(query, '"', '\\"')
	local request = utils.makeRequest(apiKey, LINEAR_API_URL, encoded_query)
	for _, value in ipairs(request["data"]["issueLabels"]["nodes"]) do
		table.insert(labels, { value["id"], value["name"] })
	end
	return labels
end

--@param apiKey string
--@return table
local function getProjectID(apiKey)
	local projects = {}
	local query = '{"query":"query IssueLabels { issueLabels { nodes { id   name } }}"}'
	local encoded_query = string.gsub(query, '"', '\\"')
	local request = utils.makeRequest(apiKey, LINEAR_API_URL, encoded_query)
	for _, value in ipairs(request["data"]["projects"]["nodes"]) do
		table.insert(projects, { value["id"], value["name"] })
	end
	return projects
end

function M.createIssue(apiKey, title, description)
	local teamID = getTeamID(apiKey)
	-- local labelID = getLabelID(apiKey)
	-- local projectID = getProjectID(apiKey)

	-- Get user to pick via ui
	local team_pick = ui.pickItem(teamID, "Team")
	print(team_pick)
	-- local label_pick = ui.pickItem(labelID, "Label")
	-- local project_pick = ui.pickItem(projectID, "Project")

	-- local query = string.format(
	-- 	[[ '{"query":"mutation IssueCreate { issueCreate( input: { title: \"%s\"  description: \"%s\"  teamId: \"%s\"  labelIds: \"%s\"  projectId: \"%s\" }){ success issue { id title }}}",}']],
	-- 	title,
	-- 	description,
	-- 	teamID,
	-- 	labelID,
	-- 	projectID
	-- )
	-- local encoded_query = string.gsub(query, '"', '\\"')
	-- local request = utils.makeRequest(apiKey, LINEAR_API_URL, encoded_query)
	-- if not request["data"]["issueCreate"]["success"] then
	-- 	print("Issue not created")
	-- end
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
					ui.showIssue(issue, selection.value.branch)
				end)
				return true
			end,
		})
		:find()
end

return M
