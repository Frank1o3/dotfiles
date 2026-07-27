return {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },

    keys = {
        { "<leader>sf", "<cmd>Telescope find_files<cr>", desc = "Search files" },
        { "<leader>sg", "<cmd>Telescope live_grep<cr>", desc = "Search text (grep)" },
        { "<leader>sb", "<cmd>Telescope buffers<cr>", desc = "Search buffers" },
        { "<leader>sr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
        { "<leader>ss", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Search symbols" },
    },

    opts = {},
}