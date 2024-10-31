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
	for key, value in pairs(self.defaults) do
		if field[key] ~= nil then
			obj[key] = field[key]
		else
			obj[key] = value
		end
	end
	return obj
end

function Issue:print_result()
	local placeholder = "Title: %s \nState: %s \nProject: %s \nAssignee: %s \nLabels: %s \nDescription: %s \nUpdates:"
	local formatted_string =
		string.format(placeholder, self.title, self.state, self.project, self.assignee, self.label, self.description)
	return vim.split(formatted_string, "\n")
end

return Issue
