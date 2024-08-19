local M = {}
local i = require("linear.issues")

M.fetchIssues = function()
	if i.validateKey() then
		i.pickIssue(i.fetchIssues())
	end
end

return M
