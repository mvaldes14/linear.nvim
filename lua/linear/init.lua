local M = {}
local api = require("linear.api")
local utils = require("linear.utils")
local issues = require("linear.issues")

M.fetchIssues = function()
	local key = utils.getKey()
	if key then
		local list_issues = api.fetchIssues()
		issues.pickIssue(list_issues)
	else
		print("API Key not found")
	end
end

M.createIssue = function()
	local key = utils.getKey()
	if key then
		issues.createIssue()
	else
		print("API Key not found")
	end
end

return M
