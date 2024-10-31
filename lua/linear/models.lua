local Issue = {}
Issue.__index = Issue

Issue.defaults = {
	assignee = "Not Assigned",
	project = "Not Defined",
	label = "Not Defined",
	title = "Not Defined",
	state = "?",
	description = "Not Available",
	updates = {
		{ comment = "Example", created = "Tomorrow", username = "John Doe" },
	},
}

-- TODO: Should return the entire table with everything on it so we don't iterate on the ui element
function Issue:new(options)
	local newIssue = setmetatable({}, self)
	for key, value in pairs(self.defaults) do
		if options[key] ~= nil then
			newIssue[key] = options[key]
		else
			newIssue[key] = value
		end
	end
	return newIssue
end

function Issue.print(issue)
	local first = "Title: %s \nState: %s \nProject: %s \nAssignee: %s \nLabels: %s \nDescription: %s \n"
	local tbl = string.format(
		first,
		issue["title"],
		issue["state"],
		issue["project"],
		issue["assignee"],
		issue["label"],
		issue["description"]
	)
	-- for _, value in ipairs(issue["updates"]) do
	-- 	second = second .. "Username" .. value["username"]
	-- 	second = second .. "Created" .. value["created"]
	-- end
	-- local result = tbl .. second
	return vim.split(tbl, "\n")
end

return Issue
