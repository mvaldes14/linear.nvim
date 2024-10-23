local M = {}

function M.init()
	state = {}
	self.__index = self
	return setmetatable(self)
end

function M.set(k, v)
	self.state[k] = v
end

function M.get()
	return self.state
end

return M
