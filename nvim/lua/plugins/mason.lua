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
            ensure_installed = require("config.workspace").mason_tools(),
            auto_update = false,
            run_on_start = true,
            start_delay = 3000,
        },
    },
}
