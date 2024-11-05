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

--@return table
function M.fetchUserID()
	local payload = '{"query":"query Nodes { users { nodes { id name } }}"}'
	local request = utils.makeRequest(LINEAR_API_URL, payload)
	return request
end

--@return table
function M.updateIssue(userID, issueID)
	if userID ~= nil or issueID ~= nil then
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
end

--@return table
function M.getTeamID()
	local teams = {}
	local payload = '{"query":"query Nodes {teams { nodes { id name }}}"}'
	local request = utils.makeRequest(LINEAR_API_URL, payload)
	for _, value in ipairs(request["data"]["teams"]["nodes"]) do
		table.insert(teams, { value["id"], value["name"] })
	end
	return teams
end

--@return table
function M.getLabelID()
	local labels = {}
	local payload = '{"query":"query Nodes {issueLabels { nodes { id name}}}"}'
	local request = utils.makeRequest(LINEAR_API_URL, payload)
	for _, value in ipairs(request["data"]["issueLabels"]["nodes"]) do
		table.insert(labels, { value["id"], value["name"] })
	end
	return labels
end

--@return table
function M.getProjectID()
	local projects = {}
	local payload = '{"query":"query Nodes { projects {  nodes {id name    }}}"}'
	local request = utils.makeRequest(LINEAR_API_URL, payload)
	for _, value in ipairs(request["data"]["projects"]["nodes"]) do
		table.insert(projects, { value["id"], value["name"] })
	end
	return projects
end

return M
