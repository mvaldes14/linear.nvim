local Issue = {}
Issue.defaults = {
	assignee = "Not Assigned",
	project = "Not Defined",
	label = "Not Defined",
	title = "Not Defined",
	state = "Not Defined",
	description = "Not Available",
}

function Issue:new(field)
	local obj = setmetatable({}, self)
	self.__index = self

	-- These are the paths returned by the API, using tbl_get prevents an invalid lookup
	local issue = {
		title = vim.tbl_get(field, "data", "issue", "title"),
		assignee = vim.tbl_get(field, "data", "issue", "assignee", "name"),
		state = vim.tbl_get(field, "data", "issue", "state", "name"),
		project = vim.tbl_get(field, "data", "issue", "project", "name"),
		label = vim.tbl_get(field, "data", "issue", "priorityLabel"),
		description = vim.tbl_get(field, "data", "issue", "description"),
	}
	for key, value in pairs(self.defaults) do
		if issue[key] ~= nil then
			obj[key] = issue[key]
		else
			obj[key] = value
		end
	end
	return obj
end

function Issue:print_result()
	local placeholder =
		"Title: %s \nState: %s \nProject: %s \nAssignee: %s \nLabels: %s \nDescription: %s \nUpdates: Below"
	local formatted_string =
		string.format(placeholder, self.title, self.state, self.project, self.assignee, self.label, self.description)
	return vim.split(formatted_string, "\n")
end

return Issue
