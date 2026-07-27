return {
    "stevearc/conform.nvim",

    opts = {
        formatters_by_ft = {
            python = { "ruff_format" },
            lua = { "stylua" },
            javascript = { "prettier" },
            typescript = { "prettier" },
            json = { "prettier" },
            yaml = { "prettier" },
            markdown = { "prettier" },
            sh = { "shfmt" },
        },

        format_on_save = false,
    },
}
