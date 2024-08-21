local M = {}
local conf = require("linear.config")

---@return string
function M.getKey()
	local linearAPICmd = conf.defaults.linear_api_cmd
	local linearAPIEnv = os.getenv("LINEAR_API_TOKEN")
	local key
	if linearAPIEnv then
		key = linearAPIEnv
	end
	if linearAPICmd then
		key = linearAPICmd
	end
	return key
end

return M
