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
vim.keymap.set("n", "<leader>po", "<cmd>UvOutdated<cr>", { desc = "uv: show outdated packages" })
vim.keymap.set("n", "<leader>pu", "<cmd>UvUpgrade<cr>", { desc = "uv: upgrade compatible packages" })
vim.keymap.set("n", "<leader>pD", "<cmd>ProjectDependencies<cr>", { desc = "Project: dependency graph and count" })
vim.keymap.set("n", "<leader>pO", "<cmd>ProjectOutdated<cr>", { desc = "Project: check outdated dependencies" })
vim.keymap.set("n", "<leader>pU", "<cmd>ProjectUpgrade<cr>", { desc = "Project: update dependencies" })
vim.keymap.set("n", "<leader>cb", "<cmd>ProjectBuild<cr>", { desc = "Build active project" })
vim.keymap.set("n", "<leader>ct", "<cmd>ProjectTest<cr>", { desc = "Test active project" })
vim.keymap.set("n", "<leader>cr", "<cmd>ProjectRun<cr>", { desc = "Run frontend dev server" })
vim.keymap.set("n", "<leader>cf", function()
    vim.lsp.buf.code_action({
        context = {
            only = { "source.fixAll.ruff" },
            diagnostics = {},
        },
        apply = true,
    })
end, { desc = "Ruff: fix all" })

-- =========================================================
-- Keyboard-only window / pane navigation (no mouse needed)
-- =========================================================
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Focus window left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Focus window down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Focus window up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Focus window right" })

vim.keymap.set("n", "<leader>|", "<cmd>vsplit<cr>", { desc = "Split vertical" })
vim.keymap.set("n", "<leader>-", "<cmd>split<cr>", { desc = "Split horizontal" })

-- Exit terminal mode without reaching for the mouse or a second terminal
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
