vim.g.mapleader = " "

vim.keymap.set("n", "<leader>w", "<cmd>write<cr>")
vim.keymap.set("n", "<leader>q", "<cmd>quit<cr>")
vim.keymap.set("n", "<leader>f", function()
    require("conform").format({
        async = true,
        lsp_fallback = true,
    })
end, { desc = "Format buffer" })

vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, {
    desc = "Show diagnostic",
})

vim.keymap.set("n", "[d", function()
    vim.diagnostic.jump({
        count = -1,
        float = true,
    })
end, {
    desc = "Previous diagnostic",
})

vim.keymap.set("n", "]d", function()
    vim.diagnostic.jump({
        count = 1,
        float = true,
    })
end, {
    desc = "Next diagnostic",
})

vim.keymap.set("n", "<leader>pi", "<cmd>UvInit<cr>", { desc = "uv: init project here" })
vim.keymap.set("n", "<leader>pa", "<cmd>UvAdd<cr>", { desc = "uv: add package" })
vim.keymap.set("n", "<leader>pd", "<cmd>UvAddDev<cr>", { desc = "uv: add dev package" })
vim.keymap.set("n", "<leader>ps", "<cmd>UvSync<cr>", { desc = "uv: sync" })
