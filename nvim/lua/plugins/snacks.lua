return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
        bigfile = { enabled = true },
        quickfile = { enabled = true },
        notifier = { enabled = true, timeout = 3000 },
        words = { enabled = true }, -- auto-highlight refs of word under cursor
        statuscolumn = { enabled = true },
        dashboard = {
            enabled = true,
            preset = {
                keys = {
                    { icon = " ", key = "f", desc = "Find File",       action = ":Telescope find_files" },
                    { icon = " ", key = "g", desc = "Live Grep",       action = ":Telescope live_grep" },
                    { icon = " ", key = "u", desc = "New uv Project",  action = ":UvInit" },
                    { icon = " ", key = "r", desc = "Recent Files",    action = ":Telescope oldfiles" },
                    { icon = " ", key = "s", desc = "Restore Session", action = ":lua require('persistence').load()" },
                    { icon = " ", key = "q", desc = "Quit",            action = ":qa" },
                },
            },
        },
    },
    keys = {
        { "<leader>un", function() Snacks.notifier.show_history() end, desc = "Notification History" },
    },
}
