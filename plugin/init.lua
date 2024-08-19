vim.api.nvim_create_user_command("LinearIssues", "lua require('linear').fetchIssues()", {})
