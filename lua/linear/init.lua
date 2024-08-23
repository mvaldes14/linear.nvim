local M = {}
local i = require("linear.issues")
local u = require("linear.utils")

M.fetchIssues = function()
	local key = u.getKey()
	if key then
		i.pickIssue(i.fetchIssues(key))
	else
		print("API Key not found")
	end
end

M.createIssue = function()
	local key = u.getKey()
	if key then
		i.createIssue(key)
	else
		print("API Key not found")
	end
end

return M
