local M = {}
local utils = require("linear.utils")
local LINEAR_API_URL = "https://api.linear.app/graphql"

---@alias issueList {branch: string, title: string, status: string}[]
---@return issueList
function M.fetchIssues()
	local issueList = {}
	local payload = '{"query": "{ issues { nodes { title state {name} branchName identifier } } }" }'
	local request = utils.makeRequest(LINEAR_API_URL, payload)
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
---@alias issueItem {title: string, status: string, description: string}
---@return issueItem
function M.fetchSingleIssue(issueID)
	local payload = {
		query = string.format(
			'query Issue { issue(id: "%s") { id title state { name } description assignee {id name} project {name} priorityLabel comments {nodes {body createdAt user{name}}}}}',
			issueID
		),
	}
	local request = utils.makeRequest(LINEAR_API_URL, vim.json.encode(payload))
	return request
end

function M.updateIssue(userID, issueID)
	local payload = {
		query = string.format(
			'mutation IssueUpdate { issueUpdate( input: { assigneeId: "%s" }id: "%s") { issue { assignee { name }}}}',
			userID,
			issueID
		),
	}
	local request = utils.makeRequest(LINEAR_API_URL, vim.json.encode(payload))
	return request
end

---@return table
-- local function getTeamID()
-- 	local teams = {}
-- 	local query = '{"query":"query Teams { teams { nodes { id name } }}"}'
-- 	local request = utils.makeRequest( LINEAR_API_URL, query)
-- 	for _, value in ipairs(request["data"]["teams"]["nodes"]) do
-- 		table.insert(teams, { value["id"], value["name"] })
-- 	end
-- 	return teams
-- end

---@return table
-- local function getLabelID()
-- 	local labels = {}
-- 	local query = '{"query":"query{ issueLabels {  nodes {  id  name }  }}"}'
-- 	local encoded_query = string.gsub(query, '"', '\\"')
-- 	local request = utils.makeRequest( LINEAR_API_URL, encoded_query)
-- 	for _, value in ipairs(request["data"]["issueLabels"]["nodes"]) do
-- 		table.insert(labels, { value["id"], value["name"] })
-- 	end
-- 	return labels
-- end

--@return table
-- local function getProjectID()
-- 	local projects = {}
-- 	local query = '{"query":"query IssueLabels { issueLabels { nodes { id   name } }}"}'
-- 	local encoded_query = string.gsub(query, '"', '\\"')
-- 	local request = utils.makeRequest( LINEAR_API_URL, encoded_query)
-- 	for _, value in ipairs(request["data"]["projects"]["nodes"]) do
-- 		table.insert(projects, { value["id"], value["name"] })
-- 	end
-- 	return projects
-- end

-- function M.createIssue(, title, description)
-- 	local teamID = getTeamID()
-- local labelID = getLabelID()
-- local projectID = getProjectID()

-- Get user to pick via ui
-- local team_pick = ui.pickItem(teamID, "Team")
-- print(team_pick)
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
-- local request = utils.makeRequest( LINEAR_API_URL, encoded_query)
-- if not request["data"]["issueCreate"]["success"] then
-- 	print("Issue not created")
-- end
-- end
return M
