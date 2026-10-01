local M = {}

local markers = {
    "Cargo.toml",
    "CMakeLists.txt",
    "pyproject.toml",
    "package.json",
    ".git",
}

local function normalize_dir(path)
    if not path or path == "" then
        return vim.uv.cwd()
    end

    if vim.fn.isdirectory(path) == 1 then
        return vim.fs.normalize(path)
    end

    return vim.fs.dirname(vim.fs.normalize(path))
end

function M.git_root(path)
    local dir = normalize_dir(path)
    local result = vim.fn.systemlist({ "git", "-C", dir, "rev-parse", "--show-toplevel" })

    if vim.v.shell_error == 0 and result[1] and result[1] ~= "" then
        return vim.fs.normalize(result[1])
    end

    return nil
end

function M.find_root(path, custom_markers)
    local dir = normalize_dir(path)
    local git = M.git_root(dir)
    if git then
        return git
    end

    local found = vim.fs.find(custom_markers or markers, {
        upward = true,
        path = dir,
    })

    if found[1] then
        return vim.fs.dirname(found[1])
    end

    return nil
end

function M.root(path)
    return M.find_root(path)
end

local function has_workspace_table(manifest)
    if vim.fn.filereadable(manifest) ~= 1 then
        return false
    end

    local content = table.concat(vim.fn.readfile(manifest), "\n")
    return content:match("%[%s*workspace%s*%]") ~= nil
end

function M.cargo_root(path)
    local dir = normalize_dir(path)
    local nearest = vim.fs.find("Cargo.toml", {
        upward = true,
        path = dir,
        type = "file",
    })[1]

    if not nearest then
        return M.git_root(dir)
    end

    local nearest_root = vim.fs.dirname(nearest)
    local git = M.git_root(dir)
    local current = nearest_root

    while current do
        local manifest = current .. "/Cargo.toml"
        if has_workspace_table(manifest) then
            return current
        end

        if git and current == git then
            break
        end

        local parent = vim.fs.dirname(current)
        if parent == current then
            break
        end
        current = parent
    end

    return nearest_root
end

function M.current_file_root()
    local name = vim.api.nvim_buf_get_name(0)
    return M.root(name ~= "" and name or vim.uv.cwd())
end

return M
