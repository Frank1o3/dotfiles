return {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",
    keys = {
        { "<S-l>",      "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
        { "<S-h>",      "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
        { "<leader>bd", "<cmd>bdelete<cr>",             desc = "Close buffer" },
        { "<leader>bp", "<cmd>BufferLinePick<cr>",      desc = "Pick buffer" },
    },
    opts = {
        options = {
            diagnostics = "nvim_lsp",
            always_show_bufferline = true,
            separator_style = "slant",
            offsets = {
                { filetype = "oil", text = "Explorer", highlight = "Directory", text_align = "left" },
            },
        },
    },
}
