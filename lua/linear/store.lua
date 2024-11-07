local Store = {}

Store.defaults = {
	team_id = "Not Defined",
	project_id = "Not Defined",
	label_id = "Not Defined",
	title = "Not Defined",
	description = "Not Defined",
}

function Store:new()
	local obj = setmetatable({}, self)
	self.__index = self
	return obj
end

function Store:get(field)
	return self[field] or "Not in Store"
end

function Store:set(field, value)
	self[field] = value
end

return Store
