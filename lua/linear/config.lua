local M = {}

M.defaults = {
	linear_api = "",
	linear_url = "https://api.linear.app/graphql",
	issues_query = '{ "query": "{ issues { nodes { id state {name} title branchName } } }" }',
}

return M
