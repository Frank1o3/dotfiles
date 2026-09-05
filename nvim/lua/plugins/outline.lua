return {
    "stevearc/aerial.nvim",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
    },
    keys = {
        { "<leader>cs", "<cmd>AerialToggle!<cr>", desc = "Symbols outline" },
        { "[y",         "<cmd>AerialPrev<cr>",    desc = "Previous symbol" },
        { "]y",         "<cmd>AerialNext<cr>",    desc = "Next symbol" },
    },
    opts = {
        backends = { "lsp", "treesitter", "markdown" },
        layout = { min_width = 28 },
        show_guides = true,
    },
}
