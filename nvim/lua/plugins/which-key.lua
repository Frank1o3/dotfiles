return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        spec = {
            { "<leader>c", group = "Code / crates" },
            { "<leader>d", group = "Debug" },
            { "<leader>g", group = "Git" },
            { "<leader>m", group = "CMake" },
            { "<leader>p", group = "Project / uv" },
            { "<leader>q", group = "Session" },
            { "<leader>r", group = "Cargo / Rust" },
            { "<leader>R", group = "Rust-analyzer" },
            { "<leader>s", group = "Search" },
            { "<leader>t", group = "Terminal / Tests" },
            { "<leader>x", group = "Diagnostics (Trouble)" },
        },
    },
}
