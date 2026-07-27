return {
    "danymat/neogen",
    dependencies = "nvim-treesitter/nvim-treesitter",
    keys = {
        { "<leader>cd", function() require("neogen").generate() end, desc = "Generate docstring" },
    },
    opts = { snippet_engine = "nvim" },
}