return {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
        { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>",       desc = "Terminal (horizontal)" },
        { "<leader>tv", "<cmd>ToggleTerm direction=vertical size=80<cr>", desc = "Terminal (vertical)" },
    },
    opts = {
        open_mapping = [[<C-\>]],
        direction = "float",
        float_opts = { border = "rounded" },
        shell = vim.o.shell,
    },
}
