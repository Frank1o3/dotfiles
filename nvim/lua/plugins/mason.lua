return {
    {
        "mason-org/mason.nvim",
        opts = {
            ui = {
                border = "rounded",
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                },
            },
        },
    },
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = { "mason-org/mason.nvim" },
        event = "VeryLazy",
        opts = {
            ensure_installed = {
                -- LSP servers (match the names used in plugins/lsp.lua)
                "lua-language-server",  -- lua_ls
                "json-lsp",             -- jsonls
                "yaml-language-server", -- yamlls
                "taplo",                -- taplo
                "ruff",                 -- ruff
                "ty",                   -- ty

                -- DAP
                "debugpy",

                -- Formatters (consumed by conform.nvim)
                "stylua",
                "shfmt",
                "prettier",
            },
            auto_update = false,
            run_on_start = true,
        },
    },
}
