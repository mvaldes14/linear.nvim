local M = {}
local conf = require("linear.config")
local curl = require("plenary.curl")

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

---@param url string
---@param body string
---@param apiKey string
---@return response any
function M.makeRequest(apiKey, url, body)
	local request = curl.post(url, {
		headers = {
			["Content-Type"] = "application/json",
			["Authorization"] = apiKey,
		},
		body = body,
	})
	if request.status ~= 200 then
		error("Failed to fetch issues")
		print(request)
	end
	-- Decode into json and grab the fields
	local payload = vim.json.decode(request.body)
	return payload
end

return M
