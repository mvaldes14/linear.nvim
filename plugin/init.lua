vim.api.nvim_create_user_command("LinearList", "lua require('linear').fetchIssues()", {})
vim.api.nvim_create_user_command("LinearCreate", "lua require('linear').createIssue()", {})
