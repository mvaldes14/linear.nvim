local M = {}
local issues = require("linear.issues")

M.fetchIssues = function()
    issues.issues()
end

return M
