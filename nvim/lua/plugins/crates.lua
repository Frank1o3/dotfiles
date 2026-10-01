return {
    "saecki/crates.nvim",
    tag = "stable",
    event = { "BufRead Cargo.toml", "BufNewFile Cargo.toml" },
    dependencies = { "saghen/blink.cmp" },
    opts = {
        completion = {
            crates = {
                enabled = true,
                min_chars = 3,
                max_results = 8,
            },
            blink = {
                use_custom_kind = true,
                kind_text = {
                    version = "Version",
                    feature = "Feature",
                },
            },
        },
        popup = {
            border = "rounded",
        },
    },
    config = function(_, opts)
        require("crates").setup(opts)

        local map = vim.keymap.set
        map("n", "<leader>cv", function() require("crates").show_versions_popup() end, { desc = "Crate versions" })
        map("n", "<leader>cf", function() require("crates").show_features_popup() end, { desc = "Crate features" })
        map("n", "<leader>cd", function() require("crates").show_dependencies_popup() end, { desc = "Crate dependencies" })
        map("n", "<leader>cu", function() require("crates").update_crate() end, { desc = "Update crate" })
        map("n", "<leader>cU", function() require("crates").upgrade_crate() end, { desc = "Upgrade crate" })
        map("n", "<leader>cC", function() require("crates").update_all_crates() end, { desc = "Update all crates" })
        map("n", "<leader>cA", function() require("crates").upgrade_all_crates() end, { desc = "Upgrade all crates" })
        map("n", "<leader>cO", function() require("crates").open_repository() end, { desc = "Crate repository" })
        map("n", "<leader>cD", function() require("crates").open_documentation() end, { desc = "Crate documentation" })
        map("n", "<leader>cH", function() require("crates").open_crates_io() end, { desc = "Open crates.io" })
    end,
}
