-- Query the Linear API to fetch issues
local M = {}
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local sorters = require("telescope.sorters")
local ui = require("linear.ui")
local api = require("linear.api")
local store = require("linear.store")

---@param issueList issueList
---@return nil
function M.pickIssue(issueList)
	pickers
		.new({}, {
			prompt_title = "Issues",
			finder = finders.new_table({
				results = issueList,
				entry_maker = function(entry)
					return {
						value = entry,
						display = "[" .. entry.branch .. "] " .. entry.title .. " (" .. entry.status .. ")",
						ordinal = "[" .. entry.branch .. "] " .. entry.title .. " (" .. entry.status .. ")",
					}
				end,
			}),
			sorter = sorters.get_generic_fuzzy_sorter(),
			attach_mappings = function(prompt_bufnr, _)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					local issue = api.fetchSingleIssue(selection.value.id)
					ui.showIssue(issue, selection.value.branch)
				end)
				return true
			end,
		})
		:find()
end

function M.createIssue()
	local s = store:new()
	local teamID = api.getTeamID()
	local labelID = api.getLabelID()
	local projectID = api.getProjectID()
	s:set("teams", teamID)
	s:set("labels", labelID)
	s:set("projects", projectID)

	ui.createIssue(s)
end

return M
