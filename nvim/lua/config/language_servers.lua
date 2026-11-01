local Workspace = require("config.workspace")

local M = {}

function M.enabled()
    local servers = {}
    if Workspace.has("Python") then
        vim.list_extend(servers, { "ty", "ruff" })
    end
    if Workspace.has("Rust") then
        table.insert(servers, "rust_analyzer")
    end
    if Workspace.has("C") or Workspace.has("C++") then
        table.insert(servers, "clangd")
    end
    if Workspace.has("CMake") then table.insert(servers, "cmake") end
    if Workspace.has("JavaScript") or Workspace.has("TypeScript") then
        vim.list_extend(servers, { "vtsls", "eslint" })
    end
    if Workspace.has("HTML") then table.insert(servers, "html") end
    if Workspace.has("CSS") then table.insert(servers, "cssls") end
    if Workspace.has("QML") then table.insert(servers, "qmlls") end
    if Workspace.has("JSON") then table.insert(servers, "jsonls") end
    if Workspace.has("YAML") then table.insert(servers, "yamlls") end
    if Workspace.has("TOML") then table.insert(servers, "taplo") end
    if Workspace.has("Lua") then table.insert(servers, "lua_ls") end
    if Workspace.has("Markdown") then table.insert(servers, "marksman") end
    return servers
end

function M.refresh()
    local servers = M.enabled()
    local wanted = {}
    for _, server in ipairs(servers) do wanted[server] = true end

    for _, client in ipairs(vim.lsp.get_clients()) do
        if ({
            ty = true, ruff = true, rust_analyzer = true, clangd = true,
            cmake = true, vtsls = true, eslint = true, html = true, cssls = true,
            qmlls = true, jsonls = true, yamlls = true,
            taplo = true, lua_ls = true, marksman = true,
        })[client.name] and not wanted[client.name] then
            vim.lsp.stop_client(client.id)
        end
    end

    local known = {
        "ty", "ruff", "rust_analyzer", "clangd", "cmake", "vtsls", "eslint", "html", "cssls", "qmlls",
        "jsonls", "yamlls", "taplo", "lua_ls",
        "marksman",
    }
    for _, server in ipairs(known) do
        vim.lsp.enable(server, wanted[server] == true)
    end
    return servers
end

return M
