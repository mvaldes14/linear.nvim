local Store = {}

Store.defaults = {
	current_issue_id = "",
	current_user_id = "",
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
