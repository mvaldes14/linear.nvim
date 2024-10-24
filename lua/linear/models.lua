local issue = {}

function issue.create(issueObject)
	local newIssue = setmetatable({}, issue)
	for key, value in pairs(issueObject) do
		newIssue[key] = value
	end
	return newIssue
end

function issue.description(desc)
	local descriptionList = {}
	local line = vim.split(desc, "\n")
	table.insert(descriptionList, line)
	return descriptionList
end

return issue
