-- Query the Linear API to fetch issues
local M = {}
local curl = require("plenary.curl")
local linearURL = "https://api.linear.app/graphql"
local linearAPI = vim.fn.getenv("LINEARTOKEN")
local issuesPayload = '{ "query": "{ issues { nodes { id title } } }" }'
local issuesResults = {}

M.fetchIssues = function()
	local request = curl.post(linearURL, {
		headers = {
			["Content-Type"] = "application/json",
			["Authorization"] = linearAPI,
		},
		body = issuesPayload,
	})
	table.insert(issuesResults, request.body)
end

return M
