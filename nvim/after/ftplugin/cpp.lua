local map = vim.keymap.set
local opts = { buffer = true, silent = true }

map("n", "<leader>ch", function()
    if vim.fn.exists(":LspClangdSwitchSourceHeader") == 2 then
        vim.cmd.LspClangdSwitchSourceHeader()
    elseif vim.fn.exists(":ClangdSwitchSourceHeader") == 2 then
        vim.cmd.ClangdSwitchSourceHeader()
    else
        vim.notify("clangd source/header command is unavailable", vim.log.levels.WARN)
    end
end, vim.tbl_extend("force", opts, { desc = "Switch source/header" }))
