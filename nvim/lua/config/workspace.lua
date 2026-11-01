local M = {
    root = nil,
    directory_arg = false,
    profile = { code_lines = 0, code = {}, configs = {}, enabled = {} },
}

M.threshold = 5

local function absolute(path)
    return vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))
end

function M.is_neovim_config(root)
    local directory = absolute(root or M.root or vim.fn.getcwd())
    for _ = 1, 6 do
        if vim.fn.filereadable(directory .. "/init.lua") == 1
            and vim.fn.isdirectory(directory .. "/lua") == 1 then
            return true
        end
        local nvim = directory .. "/nvim"
        if vim.fn.filereadable(nvim .. "/init.lua") == 1 and vim.fn.isdirectory(nvim .. "/lua") == 1 then
            return true
        end
        local parent = vim.fs.dirname(directory)
        if parent == directory then break end
        directory = parent
    end
    return false
end

local code_extensions = {
    py = "Python", pyw = "Python", pyi = "Python",
    rs = "Rust",
    c = "C", h = "Header",
    cc = "C++", cpp = "C++", cxx = "C++", hh = "C++", hpp = "C++", hxx = "C++", mm = "C++",
    js = "JavaScript", jsx = "JavaScript", mjs = "JavaScript", cjs = "JavaScript",
    ts = "TypeScript", tsx = "TypeScript", mts = "TypeScript", cts = "TypeScript",
    lua = "Lua", go = "Go", java = "Java", kt = "Kotlin", kts = "Kotlin",
    cs = "C#", rb = "Ruby", php = "PHP", swift = "Swift",
    sh = "Shell", bash = "Shell", zsh = "Shell", fish = "Shell",
    html = "HTML", css = "CSS", scss = "CSS", sass = "CSS", less = "CSS", sql = "SQL", qml = "QML",
    zig = "Zig", hs = "Haskell", ex = "Elixir", exs = "Elixir", cmake = "CMake",
}

local config_extensions = {
    json = "JSON", jsonc = "JSON", json5 = "JSON",
    yaml = "YAML", yml = "YAML",
    toml = "TOML",
}

local function find_root()
    local args = vim.fn.argv()
    local first = args[1]
    if first and first ~= "" then
        local path = absolute(first)
        local stat = vim.uv.fs_stat(path)
        if stat and stat.type == "directory" then
            return path, true
        end
        if stat and stat.type == "file" then
            return vim.fs.root(path, {
                ".git", "Cargo.toml", "pyproject.toml", "CMakeLists.txt", "meson.build",
                "Makefile", "package.json", "go.mod", "pom.xml",
            }) or vim.fs.dirname(path), false
        end
    end

    local cwd = absolute(vim.fn.getcwd())
    return vim.fs.root(cwd, {
        ".git", "Cargo.toml", "pyproject.toml", "CMakeLists.txt", "meson.build",
        "Makefile", "package.json", "go.mod", "pom.xml",
    }) or cwd, #args == 0
end

local function scan_files(root)
    if vim.fn.executable("rg") == 1 then
        local args = {
            "rg", "--count", "--hidden", "--no-messages",
            "--glob", "!**/.git/**",
            "--glob", "!**/target/**",
            "--glob", "!**/node_modules/**",
            "--glob", "!**/.venv/**",
            "--glob", "!**/build/**",
            "--glob", "!**/dist/**",
            "--glob", "!**/__pycache__/**",
            "--glob", "!**/.cache/**",
            "^",
            root,
        }
        local result = vim.fn.systemlist(args)
        if vim.v.shell_error == 0 or vim.v.shell_error == 1 then
            local files = {}
            for _, entry in ipairs(result) do
                local path, lines = entry:match("^(.*):(%d+)$")
                if path then table.insert(files, { path = path, lines = tonumber(lines) or 0 }) end
            end
            return files
        end
    end

    local git_files = vim.fn.systemlist({ "git", "-C", root, "ls-files", "--cached", "--others", "--exclude-standard" })
    if vim.v.shell_error == 0 then
        local files = {}
        for _, path in ipairs(git_files) do table.insert(files, { path = path, lines = 1 }) end
        return files
    end
    return {}
end

local function count_languages(root)
    local code, configs, ambiguous_headers, markdown_files = {}, {}, 0, 0
    for _, file in ipairs(scan_files(root)) do
        local relative_path = file.path
        local basename = relative_path:match("([^/]+)$")
        local extension = relative_path:match("%.([^./]+)$")
        if extension and extension:lower() == "md" then
            markdown_files = markdown_files + 1
        end
        if basename == "CMakeLists.txt" then
            code.CMake = (code.CMake or 0) + file.lines
        end
        if extension then
            extension = extension:lower()
            local language = code_extensions[extension]
            if language == "Header" then
                ambiguous_headers = ambiguous_headers + file.lines
            elseif language then
                code[language] = (code[language] or 0) + file.lines
            end
            language = config_extensions[extension]
            if language then
                configs[language] = (configs[language] or 0) + 1
            end
        end
    end

    local c_count, cpp_count = code.C or 0, code["C++"] or 0
    if c_count > 0 and cpp_count > 0 then
        code.C = c_count + math.ceil(ambiguous_headers / 2)
        code["C++"] = cpp_count + math.floor(ambiguous_headers / 2)
    elseif cpp_count > 0 then
        code["C++"] = cpp_count + ambiguous_headers
    else
        code.C = c_count + ambiguous_headers
    end

    local total = 0
    for _, count in pairs(code) do total = total + count end
    return { code_lines = total, code = code, configs = configs, markdown_files = markdown_files, enabled = {} }
end

local function selected(profile, language)
    if profile.code_lines == 0 then return false end
    return ((profile.code[language] or 0) / profile.code_lines * 100) >= M.threshold
end

local function configure_profile(profile)
    local enabled = {}
    for language in pairs(profile.code) do
        if selected(profile, language) then
            enabled[language] = true
        end
    end
    if (profile.code.CMake or 0) > 0 then enabled.CMake = true end
    -- Small HTML/CSS portions are still essential in front-end projects.
    if (profile.code.HTML or 0) > 0 then enabled.HTML = true end
    if (profile.code.CSS or 0) > 0 then enabled.CSS = true end
    if (profile.markdown_files or 0) > 0 then enabled.Markdown = true end
    -- Keep the editor self-hosting: LuaLS, StyLua, and Tree-sitter remain
    -- available when this workspace contains the Neovim config itself.
    if M.is_neovim_config(M.root) then enabled.Lua = true end
    profile.enabled = enabled

    -- Config-file language servers are inexpensive and useful even when a
    -- project contains only a handful of manifests or settings files.
    for language, count in pairs(profile.configs) do
        if count > 0 then enabled[language] = true end
    end
    return profile
end

function M.scan(root)
    M.root = absolute(root or vim.fn.getcwd())
    M.profile = configure_profile(count_languages(M.root))
    return M.profile
end

function M.has(language)
    return M.profile.enabled[language] == true
end

function M.enabled_languages()
    local languages = {}
    for language, enabled in pairs(M.profile.enabled) do
        if enabled then table.insert(languages, language) end
    end
    table.sort(languages)
    return languages
end

function M.summary()
    local rows = {}
    for language, count in pairs(M.profile.code) do
        table.insert(rows, { language = language, count = count, percent = count / math.max(1, M.profile.code_lines) * 100 })
    end
    table.sort(rows, function(a, b) return a.count > b.count end)

    local parts = {}
    for _, row in ipairs(rows) do
        table.insert(parts, string.format("%s %.1f%%", row.language, row.percent))
    end
    for _, language in ipairs({ "JSON", "YAML", "TOML" }) do
        local count = M.profile.configs[language]
        if count then
            table.insert(parts, string.format("%s (%d files)", language, count))
        end
    end
    if (M.profile.markdown_files or 0) > 0 then
        table.insert(parts, string.format("Markdown (%d files)", M.profile.markdown_files))
    end

    if #parts == 0 then return "No recognized source files" end
    return table.concat(parts, " · ")
end

function M.mason_tools()
    local tools = {}
    local function add(...)
        for _, tool in ipairs({ ... }) do table.insert(tools, tool) end
    end

    if M.has("Python") then add("ty", "ruff", "debugpy") end
    if M.has("Rust") then add("rust-analyzer") end
    if M.has("C") or M.has("C++") then add("clangd", "clang-format") end
    if M.has("CMake") then add("cmake-language-server") end
    if M.has("JavaScript") or M.has("TypeScript") then add("vtsls", "prettier") end
    if M.has("JavaScript") or M.has("TypeScript") then add("eslint-lsp") end
    if M.has("HTML") then add("html-lsp", "prettier") end
    if M.has("CSS") then add("css-lsp", "prettier") end
    if M.has("Lua") then add("lua-language-server", "stylua") end
    if M.has("Markdown") then add("marksman", "prettier") end
    if M.has("JSON") then add("json-lsp", "prettier") end
    if M.has("YAML") then add("yaml-language-server", "prettier") end
    if M.has("TOML") then add("taplo") end
    if M.has("Shell") then add("shfmt") end
    if M.has("Python") or M.has("JavaScript") or M.has("TypeScript") or M.has("JSON") or M.has("YAML") then
        add("prettier")
    end

    local unique, result = {}, {}
    for _, tool in ipairs(tools) do
        if not unique[tool] then
            unique[tool] = true
            table.insert(result, tool)
        end
    end
    return result
end

function M.treesitter_languages()
    local parsers = { "markdown", "markdown_inline", "gitignore" }
    local function add_if(language, parser)
        if M.has(language) then table.insert(parsers, parser) end
    end

    add_if("Python", "python")
    add_if("Rust", "rust")
    add_if("C", "c")
    add_if("C++", "cpp")
    add_if("JavaScript", "javascript")
    add_if("TypeScript", "typescript")
    add_if("TypeScript", "tsx")
    add_if("QML", "qmljs")
    add_if("CMake", "cmake")
    add_if("Lua", "lua")
    add_if("JSON", "json")
    add_if("YAML", "yaml")
    add_if("TOML", "toml")
    add_if("Shell", "bash")
    add_if("HTML", "html")
    add_if("CSS", "css")

    local result, seen = {}, {}
    for _, parser in ipairs(parsers) do
        if not seen[parser] then
            seen[parser] = true
            table.insert(result, parser)
        end
    end
    return result
end

local function find_readme(root)
    for _, name in ipairs({ "README.md", "README.MD", "readme.md", "README", "Readme.md" }) do
        local path = root .. "/" .. name
        if vim.fn.filereadable(path) == 1 then return path end
    end
end

local function show_workspace()
    if not M.root then return end
    vim.cmd.cd(M.root)

    local current = vim.api.nvim_buf_get_name(0)
    if M.directory_arg or (current ~= "" and vim.fn.isdirectory(current) == 1) then
        vim.cmd.enew()
    end

    local readme = find_readme(M.root)
    if readme and (current == "" or vim.fn.isdirectory(current) == 1) then
        vim.cmd.edit(vim.fn.fnameescape(readme))
    end

    vim.schedule(function()
        if vim.fn.exists(":Neotree") == 2 then
            vim.cmd("Neotree filesystem show left dir=" .. vim.fn.fnameescape(M.root))
        end
        vim.notify("Workspace: " .. M.summary(), vim.log.levels.INFO, { title = "Project languages" })
    end)
end

function M.setup()
    local root, directory_arg = find_root()
    M.directory_arg = directory_arg
    M.scan(root)
    vim.g.project_root = M.root

    vim.api.nvim_create_user_command("ProjectLanguages", function()
        vim.notify(M.summary(), vim.log.levels.INFO, { title = "Project languages" })
    end, { desc = "Show project language percentages" })

    vim.api.nvim_create_user_command("ProjectRescan", function()
        M.scan(vim.fn.getcwd())
        vim.g.project_root = M.root
        vim.notify("Workspace: " .. M.summary(), vim.log.levels.INFO, { title = "Project languages" })
        require("config.language_servers").refresh()
    end, { desc = "Rescan languages and update enabled language servers" })

    if directory_arg then
        vim.api.nvim_create_autocmd("VimEnter", {
            once = true,
            callback = show_workspace,
        })
    elseif #vim.fn.argv() == 0 and find_readme(M.root) then
        vim.api.nvim_create_autocmd("VimEnter", {
            once = true,
            callback = show_workspace,
        })
    end
end

return M
