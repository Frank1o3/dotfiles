local Workspace = require("config.workspace")
local formatters = {}

if Workspace.has("Python") then formatters.python = { "ruff_format" } end
if Workspace.has("Rust") then formatters.rust = { "rustfmt" } end
if Workspace.has("C") then formatters.c = { "clang_format" } end
if Workspace.has("C++") then formatters.cpp = { "clang_format" } end
if Workspace.has("QML") then formatters.qml = { "qmlformat" } end
if Workspace.has("Lua") then formatters.lua = { "stylua" } end
if Workspace.has("JavaScript") then
    formatters.javascript = { "prettier" }
    formatters.javascriptreact = { "prettier" }
end
if Workspace.has("TypeScript") then
    formatters.typescript = { "prettier" }
    formatters.typescriptreact = { "prettier" }
end
if Workspace.has("HTML") then formatters.html = { "prettier" } end
if Workspace.has("CSS") then
    formatters.css = { "prettier" }
    formatters.scss = { "prettier" }
    formatters.less = { "prettier" }
    formatters.sass = { "prettier" }
end
if Workspace.has("JSON") then formatters.json = { "prettier" } end
if Workspace.has("YAML") then formatters.yaml = { "prettier" } end
if Workspace.has("TOML") then formatters.toml = { "taplo" } end
if Workspace.has("Markdown") then
    formatters.markdown = { "prettier" }
end
if Workspace.has("Shell") then formatters.sh = { "shfmt" } end

return {
    "stevearc/conform.nvim",
    opts = {
        formatters_by_ft = formatters,
        format_on_save = false,
    },
}
