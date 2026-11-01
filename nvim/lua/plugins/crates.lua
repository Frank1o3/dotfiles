return {
    "saecki/crates.nvim",
    tag = "stable",
    cond = function() return require("config.workspace").has("Rust") end,
    event = { "BufRead Cargo.toml" },
    config = function()
        local crates = require("crates")
        crates.setup({
            lsp = {
                enabled = true,
                actions = true,
                completion = true,
                hover = true,
            },
            completion = {
                crates = {
                    enabled = true,
                    min_chars = 3,
                    max_results = 8,
                },
            },
        })

        local opts = { buffer = true, silent = true }
        vim.keymap.set("n", "<leader>ru", crates.update_crate, vim.tbl_extend("force", opts, { desc = "Crates: update to compatible" }))
        vim.keymap.set("n", "<leader>rU", crates.upgrade_crate, vim.tbl_extend("force", opts, { desc = "Crates: upgrade current" }))
        vim.keymap.set("n", "<leader>rA", crates.upgrade_all_crates, vim.tbl_extend("force", opts, { desc = "Crates: upgrade all" }))
        vim.keymap.set("n", "<leader>rv", crates.show_versions_popup, vim.tbl_extend("force", opts, { desc = "Crates: versions" }))
    end,
}
