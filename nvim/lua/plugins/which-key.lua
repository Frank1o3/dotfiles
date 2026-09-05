return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        spec = {
            { "<leader>c", group = "Code" },
            { "<leader>d", group = "Debug" },
            { "<leader>g", group = "Git" },
            { "<leader>p", group = "Project (uv)" },
            { "<leader>q", group = "Session" },
            { "<leader>s", group = "Search" },
            { "<leader>t", group = "Terminal" },
            { "<leader>x", group = "Diagnostics (Trouble)" },
        },
    },
}
