-- Query the Linear API to fetch issues
local curl = require("plenary.curl")
local linearURL = "https://api.linear.app/graphql"
local linearAPI = vim.fn.getenv("LINEARTOKEN")
local issuesPayload = '{ "query": "{ issues { nodes { id state {name} title branchName } } }" }'
local issueList = {}

local function fetchIssues()
	if linearAPI ~= nil then
		local request = curl.post(linearURL, {
			headers = {
				["Content-Type"] = "application/json",
				["Authorization"] = linearAPI,
			},
			body = issuesPayload,
		})
		-- decode into json and grab the fields
		local payload = vim.json.decode(request.body)
		for _, value in ipairs(payload["data"]["issues"]["nodes"]) do
			local title = value["title"]
			local status = value["state"]["name"]
			local branch = value["branchName"]
			local issue = { branch = branch, title = title, status = status }
			table.insert(issueList, issue)
		end
	end
end

fetchIssues()
print(issueList)
