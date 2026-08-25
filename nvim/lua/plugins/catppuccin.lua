return {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,

    opts = {
        integrations = {
            blink_cmp = true,
            lualine = true, -- ← this is what registers the "catppuccin" lualine theme
            native_lsp = { enabled = true },
            treesitter = true,
            telescope = { enabled = true },
            gitsigns = true,
            which_key = true,
            indent_blankline = { enabled = true },
            notify = true,
            fidget = true,
            dap = true,
            dap_ui = true,
            neotest = true,
            snacks = true,
        },
    },

    config = function(_, opts)
        require("catppuccin").setup(opts)
        vim.cmd.colorscheme("catppuccin")
    end,
}
