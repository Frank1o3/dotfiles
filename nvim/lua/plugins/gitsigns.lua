return {
    "lewis6991/gitsigns.nvim",

    opts = {
        signs = {
            add = { text = "│" },
            change = { text = "│" },
            delete = { text = "_" },
            topdelete = { text = "‾" },
            changedelete = { text = "~" },
        },
    },

    keys = {
        {
            "]c",
            function()
                if vim.wo.diff then
                    vim.cmd.normal({ "]c", bang = true })
                else
                    require("gitsigns").nav_hunk("next")
                end
            end,
            desc = "Next Git hunk",
        },

        {
            "[c",
            function()
                if vim.wo.diff then
                    vim.cmd.normal({ "[c", bang = true })
                else
                    require("gitsigns").nav_hunk("prev")
                end
            end,
            desc = "Previous Git hunk",
        },

        {
            "<leader>hs",
            function()
                require("gitsigns").stage_hunk()
            end,
            desc = "Stage hunk",
        },

        {
            "<leader>hr",
            function()
                require("gitsigns").reset_hunk()
            end,
            desc = "Reset hunk",
        },

        {
            "<leader>hp",
            function()
                require("gitsigns").preview_hunk()
            end,
            desc = "Preview hunk",
        },

        {
            "<leader>hb",
            function()
                require("gitsigns").blame_line()
            end,
            desc = "Blame line",
        },

        {
            "<leader>hd",
            function()
                require("gitsigns").diffthis()
            end,
            desc = "Diff current file",
        },
    },
}