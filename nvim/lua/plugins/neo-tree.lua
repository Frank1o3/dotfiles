return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
    },
    cmd = "Neotree",
    keys = {
        { "<leader>e",  "<cmd>Neotree toggle reveal<cr>",    desc = "Toggle file explorer" },
        { "<leader>ge", "<cmd>Neotree float git_status<cr>", desc = "Git status explorer" },
    },
    opts = {
        close_if_last_window = true,
        window = {
            width = 32,
        },
        filesystem = {
            -- Oil already owns netrw / directory-as-buffer editing;
            -- Neo-tree here is purely an explicit sidebar.
            hijack_netrw_behavior = "disabled",
            follow_current_file = { enabled = true },
            use_libuv_file_watcher = true,
            filtered_items = {
                hide_dotfiles = false,
                hide_gitignored = false,
            },
        },
        default_component_configs = {
            git_status = {
                symbols = {
                    added = "✚",
                    modified = "",
                    deleted = "✖",
                    renamed = "➜",
                    untracked = "★",
                    ignored = "",
                    unstaged = "",
                    staged = "",
                    conflict = "",
                },
            },
        },
    },
}
