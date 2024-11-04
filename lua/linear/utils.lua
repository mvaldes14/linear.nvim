local M = {}
local conf = require("linear.config")
local curl = require("plenary.curl")

---@param url string
---@param body string
---@return response table
function M.makeRequest(url, body)
	local key = M.getKey()
	local request = curl.post(url, {
		headers = {
			["Content-Type"] = "application/json",
			["Authorization"] = key,
		},
		body = body,
	})
	if request.status ~= 200 then
		error("Faild to fetch issues")
		print(request)
	end
	-- Decode into json and grab the fields
	local payload = vim.json.decode(request.body)
	return payload
end

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
