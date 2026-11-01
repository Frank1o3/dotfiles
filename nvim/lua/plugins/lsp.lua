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
            vim.lsp.config("eslint", {
                capabilities = caps,
                settings = {
                    workingDirectory = { mode = "auto" },
                    codeActionOnSave = { enable = false },
                },
            })
        end

        if Workspace.has("HTML") then
            vim.lsp.config("html", { capabilities = caps })
        end
        if Workspace.has("CSS") then
            vim.lsp.config("cssls", { capabilities = caps })
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

        if Workspace.has("Lua") then
            local lua_settings = {
                Lua = {
                    diagnostics = { globals = { "vim" } },
                    workspace = { checkThirdParty = false },
                    telemetry = { enable = false },
                },
            }
            if Workspace.is_neovim_config() then
                lua_settings.Lua.runtime = { version = "LuaJIT" }
                lua_settings.Lua.workspace.library = vim.api.nvim_get_runtime_file("", true)
                lua_settings.Lua.completion = { callSnippet = "Replace" }
            end
            vim.lsp.config("lua_ls", {
                capabilities = caps,
                settings = lua_settings,
                root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", "stylua.toml", "init.lua", ".git" },
            })
        end

        if Workspace.has("Markdown") then
            vim.lsp.config("marksman", {
                capabilities = caps,
                root_markers = { ".marksman.toml", ".git" },
            })
        end

        require("config.language_servers").refresh()
    end,
}
