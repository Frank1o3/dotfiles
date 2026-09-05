return {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
    keys = {
        { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Diagnostics (workspace)" },
        { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Diagnostics (buffer)" },
        { "<leader>xq", "<cmd>Trouble qflist toggle<cr>",                   desc = "Quickfix list" },
        { "<leader>xl", "<cmd>Trouble loclist toggle<cr>",                  desc = "Location list" },
        { "<leader>cr", "<cmd>Trouble lsp_references toggle<cr>",           desc = "LSP references" },
        { "<leader>cy", "<cmd>Trouble symbols toggle focus=false<cr>",      desc = "Workspace symbols" },
    },
    opts = {},
}
