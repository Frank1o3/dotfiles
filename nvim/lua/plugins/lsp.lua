return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "mason-org/mason.nvim",
        "b0o/schemastore.nvim",
    },
    config = function()
        local caps = require("blink.cmp").get_lsp_capabilities()

        vim.lsp.config("clangd", {
            capabilities = caps,
            cmd = {
                "clangd",
                "--background-index",
                "--clang-tidy",
                "--header-insertion=iwyu",
            },
        })

        vim.lsp.config("ty", {
            cmd = { "ty", "server" },
            capabilities = caps,
        })

        vim.lsp.config("ruff", {
            cmd = { "ruff", "server" },
            capabilities = caps,
            init_options = {
                settings = {
                    lint = { enable = true },
                    organizeImports = true,
                },
            },
        })

        vim.lsp.config("jsonls", {
            capabilities = caps,
            settings = {
                json = {
                    schemas = require("schemastore").json.schemas(),
                    validate = { enable = true },
                },
            },
        })

        vim.lsp.config("yamlls", {
            capabilities = caps,
            settings = {
                yaml = {
                    schemaStore = { enable = false, url = "" },
                    schemas = require("schemastore").yaml.schemas(),
                },
            },
        })

        vim.lsp.config("taplo", { capabilities = caps })

        vim.lsp.config("lua_ls", {
            capabilities = caps,
            settings = {
                Lua = {
                    diagnostics = { globals = { "vim" } },
                    workspace = { checkThirdParty = false },
                    telemetry = { enable = false },
                },
            },
        })

        -- Rust is intentionally omitted: rustaceanvim owns rust-analyzer.
        vim.lsp.enable({
            "clangd",
            "ty",
            "ruff",
            "jsonls",
            "yamlls",
            "taplo",
            "lua_ls",
        })
    end,
}
