return {
    "neovim/nvim-lspconfig",
    dependencies = { "mason-org/mason.nvim" },

    config = function()
        local Workspace = require("config.workspace")
        local caps = require("blink.cmp").get_lsp_capabilities()

        if Workspace.has("Python") then
            vim.lsp.config("ty", {
                cmd = { "ty", "server" },
                capabilities = caps,
                settings = {
                    ty = {
                        diagnosticMode = "workspace",
                    },
                },
            })

            vim.lsp.config("ruff", {
                cmd = { "ruff", "server" },
                capabilities = caps,
                init_options = {
                    settings = {
                        -- Ty handles types and navigation; Ruff handles linting and fixes.
                        lint = { enable = true },
                        organizeImports = true,
                    },
                },
            })
        end

        if Workspace.has("Rust") then vim.lsp.config("rust_analyzer", {
            capabilities = caps,
            settings = {
                ["rust-analyzer"] = {
                    cargo = {
                        allTargets = true,
                        buildScripts = { enable = true },
                    },
                    procMacro = { enable = true },
                    check = {
                        command = "clippy",
                    },
                    diagnostics = {
                        styleLints = { enable = true },
                    },
                },
            },
        }) end

        if Workspace.has("C") or Workspace.has("C++") then vim.lsp.config("clangd", {
            cmd = {
                "clangd",
                "--background-index",
                "--clang-tidy",
                "--completion-style=detailed",
                "--header-insertion=iwyu",
            },
            capabilities = caps,
            root_markers = {
                "compile_commands.json",
                "compile_flags.txt",
                "CMakeLists.txt",
                "meson.build",
                "Makefile",
                ".git",
            },
        }) end

        if Workspace.has("CMake") then
            vim.lsp.config("cmake", {
                capabilities = caps,
                init_options = { buildDirectory = "build" },
            })
        end

        if Workspace.has("JavaScript") or Workspace.has("TypeScript") then
            vim.lsp.config("vtsls", { capabilities = caps })
        end

        if Workspace.has("QML") then vim.lsp.config("qmlls", {
            cmd = { "qmlls" },
            capabilities = caps,
            filetypes = { "qml", "qmljs" },
            root_markers = { ".qmlls.ini", "CMakeLists.txt", ".git" },
        }) end

        if Workspace.has("JSON") then vim.lsp.config("jsonls", {
            capabilities = caps,
            settings = {
                json = {
                    schemas = require("schemastore").json.schemas(),
                    validate = { enable = true },
                },
            },
        }) end

        if Workspace.has("YAML") then vim.lsp.config("yamlls", {
            capabilities = caps,
            settings = {
                yaml = {
                    schemaStore = { enable = false, url = "" },
                    schemas = require("schemastore").yaml.schemas(),
                },
            },
        }) end

        if Workspace.has("TOML") then
            vim.lsp.config("taplo", { capabilities = caps })
        end

        if Workspace.has("Lua") then vim.lsp.config("lua_ls", {
            capabilities = caps,
            settings = {
                Lua = {
                    diagnostics = { globals = { "vim" } },
                    workspace = { checkThirdParty = false },
                    telemetry = { enable = false },
                },
            },
        }) end

        require("config.language_servers").refresh()
    end,
}
