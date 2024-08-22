local config = require("linear.config")
describe("config", function()
	-- Test if the api key cmd is not empty
	it("Api Cmd Key Empty", function()
		local api_key_cmd = config.defaults.api_key_cmd
		assert.truthy(api_key_cmd)
	end)

	-- Test if the environment variable is set
	it("Api key env variable", function()
		local api_key = os.getenv("LINEAR_API_KEY")
		assert.truthy(api_key)
	end)
end)
