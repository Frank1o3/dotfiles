return {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    keys = {
        { "<leader>qs", function() require("persistence").load() end,                desc = "Restore session" },
        { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
    },
}
