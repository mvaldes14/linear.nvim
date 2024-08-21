local config = require("linear.conf")

describe("config", function()
	it("Api Key Not Empty", function()
		local api_key_cmd = config.defaults.linear_api_cmd
		assert.truthy(api_key_cmd)
	end)
end)
