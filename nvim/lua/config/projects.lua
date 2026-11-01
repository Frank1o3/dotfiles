local M = {}
local Workspace = require("config.workspace")

local function root_for(bufnr)
    local file = vim.api.nvim_buf_get_name(bufnr)
    local filetype = vim.bo[bufnr].filetype
    local markers

    if filetype == "rust" then
        markers = { "Cargo.toml", ".git" }
    elseif filetype == "python" then
        markers = { "pyproject.toml", "uv.lock", "pytest.ini", "setup.cfg", "tox.ini", ".git" }
    elseif filetype == "c" or filetype == "cpp" or filetype == "objc" or filetype == "objcpp" or filetype == "qml" or filetype == "cmake" then
        markers = {
            "CMakeLists.txt",
            "meson.build",
            "Makefile",
            "makefile",
            "build.ninja",
            "compile_commands.json",
            ".git",
        }
    else
        -- Project commands should still work while the README or an empty
        -- startup buffer is focused. Pick a supported language from the
        -- workspace profile in that case.
        local priority = { "Rust", "Python", "C++", "C", "QML", "TypeScript", "JavaScript" }
        for _, language in ipairs(priority) do
            if Workspace.has(language) then
                filetype = ({
                    Rust = "rust", Python = "python", ["C++"] = "cpp", C = "c", QML = "qml",
                    TypeScript = "typescript", JavaScript = "javascript",
                })[language]
                break
            end
        end
        if not filetype then return nil, filetype end
        return Workspace.root or vim.fn.getcwd(), filetype
    end

    if file ~= "" then
        return vim.fs.root(file, markers) or vim.fn.getcwd(), filetype
    end

    return vim.fn.getcwd(), filetype
end

local function shell_command(argv)
    return table.concat(vim.tbl_map(vim.fn.shellescape, argv), " ")
end

local function launch(root, commands)
    local command = table.concat(vim.tbl_map(shell_command, commands), " && ")
    vim.cmd("botright 15split")
    vim.fn.termopen(command, { cwd = root })
    vim.cmd("startinsert")
end

local function rust_commands(action)
    if action == "build" then
        return { { "cargo", "build" } }
    end
    return { { "cargo", "test" } }
end

local function python_commands(root, action)
    local has_uv = vim.fn.executable("uv") == 1
    if action == "build" then
        if has_uv and (vim.fn.filereadable(root .. "/uv.lock") == 1 or vim.fn.filereadable(root .. "/pyproject.toml") == 1) then
            return { { "uv", "sync" } }
        end
        return { { "python", "-m", "compileall", "-q", "." } }
    end

    if has_uv and (vim.fn.filereadable(root .. "/uv.lock") == 1 or vim.fn.filereadable(root .. "/pyproject.toml") == 1) then
        return { { "uv", "run", "pytest" } }
    end
    return { { "python", "-m", "pytest" } }
end

local function javascript_commands(root, action)
    local package_json = root .. "/package.json"
    if vim.fn.filereadable(package_json) ~= 1 then return nil end
    local ok, manifest = pcall(vim.json.decode, table.concat(vim.fn.readfile(package_json), "\n"))
    local script = action == "build" and "build" or "test"
    if not ok or not manifest.scripts or not manifest.scripts[script] then
        return nil
    end

    local manager = vim.fn.filereadable(root .. "/pnpm-lock.yaml") == 1 and "pnpm"
        or (vim.fn.filereadable(root .. "/yarn.lock") == 1 and "yarn" or "npm")
    return { { manager, "run", script } }
end

local function native_commands(root, action)
    if vim.fn.filereadable(root .. "/CMakeLists.txt") == 1 then
        local build_dir = root .. "/build"
        local commands = {
            { "cmake", "-S", root, "-B", build_dir, "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON" },
            { "cmake", "--build", build_dir, "--parallel" },
        }
        if action == "test" then
            table.insert(commands, { "ctest", "--test-dir", build_dir, "--output-on-failure" })
        end
        return commands
    end

    if vim.fn.filereadable(root .. "/meson.build") == 1 then
        local build_dir = root .. "/build"
        local setup = vim.fn.isdirectory(build_dir) == 1
            and { "meson", "setup", build_dir, root, "--reconfigure" }
            or { "meson", "setup", build_dir, root }
        local commands = { setup }
        table.insert(commands, action == "test"
            and { "meson", "test", "-C", build_dir, "--print-errorlogs" }
            or { "meson", "compile", "-C", build_dir })
        return commands
    end

    if vim.fn.filereadable(root .. "/Makefile") == 1 or vim.fn.filereadable(root .. "/makefile") == 1 then
        return { action == "test" and { "make", "-C", root, "test" } or { "make", "-C", root, "-j" } }
    end

    if vim.fn.filereadable(root .. "/build.ninja") == 1 then
        return { action == "test" and { "ninja", "-C", root, "test" } or { "ninja", "-C", root } }
    end

    return nil
end

function M.run(action)
    local root = Workspace.root or root_for(0)
    if not root then
        vim.notify("No build or test task is defined for this filetype", vim.log.levels.WARN, { title = "Project" })
        return
    end

    local commands = {}
    if Workspace.has("Rust") and vim.fn.filereadable(root .. "/Cargo.toml") == 1 then
        vim.list_extend(commands, rust_commands(action))
    end
    if Workspace.has("Python") and vim.fn.filereadable(root .. "/pyproject.toml") == 1 then
        vim.list_extend(commands, python_commands(root, action))
    end
    if Workspace.has("C") or Workspace.has("C++") or Workspace.has("QML") or Workspace.has("CMake") then
        vim.list_extend(commands, native_commands(root, action) or {})
    end
    if Workspace.has("JavaScript") or Workspace.has("TypeScript") then
        vim.list_extend(commands, javascript_commands(root, action) or {})
    end

    if #commands == 0 then
        vim.notify("No supported build file found under " .. root, vim.log.levels.WARN, { title = "Project" })
        return
    end

    launch(root, commands)
end

local function show_report(title, body)
    local buf = vim.api.nvim_create_buf(false, true)
    local lines = vim.split(body, "\n", { trimempty = true })
    if #lines == 0 then lines = { "No dependencies found." } end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = "text"
    vim.cmd("botright 16split")
    vim.api.nvim_win_set_buf(0, buf)
    vim.api.nvim_buf_set_name(buf, title)
    vim.bo[buf].modifiable = false
end

local function dependency_graph(root, filetype)
    local command, label
    if filetype == "rust" then
        command = { "cargo", "tree", "--workspace", "--depth", "1" }
        label = "Cargo dependencies"
    elseif filetype == "python" then
        command = { "uv", "tree", "--depth", "1" }
        label = "Python dependencies"
    elseif (filetype == "javascript" or filetype == "typescript")
        and vim.fn.filereadable(root .. "/package.json") == 1 then
        local manager = vim.fn.filereadable(root .. "/pnpm-lock.yaml") == 1 and "pnpm"
            or (vim.fn.filereadable(root .. "/yarn.lock") == 1 and "yarn" or "npm")
        command = manager == "pnpm" and { "pnpm", "list", "--depth", "Infinity" }
            or (manager == "yarn" and { "yarn", "list", "--depth=999" } or { "npm", "ls", "--all" })
        label = "JavaScript dependencies"
    elseif (filetype == "c" or filetype == "cpp" or filetype == "qml" or filetype == "cmake")
        and vim.fn.filereadable(root .. "/CMakeLists.txt") == 1 then
        local graph = root .. "/build/dependencies.dot"
        command = {
            "cmake", "--graphviz=" .. graph,
            "-S", root, "-B", root .. "/build",
            "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
        }
        label = "CMake dependency graph"
    else
        vim.notify("No dependency graph command is configured for this project", vim.log.levels.WARN, { title = "Project" })
        return
    end

    vim.system(command, { cwd = root, text = true }, function(result)
        vim.schedule(function()
            local output = result.stdout or ""
            if result.code ~= 0 then
                output = (result.stderr or "Dependency command failed.") .. "\n" .. output
            elseif label == "CMake dependency graph" then
                local graph = root .. "/build/dependencies.dot"
                local graph_lines = vim.fn.filereadable(graph) == 1 and vim.fn.readfile(graph) or {}
                local edges = 0
                for _, line in ipairs(graph_lines) do
                    if line:match("%-%>") then edges = edges + 1 end
                end
                output = string.format("CMake target graph: %d dependency edges\n%s", edges, table.concat(graph_lines, "\n"))
            else
                local direct, nodes = 0, 0
                for line in output:gmatch("[^\n]+") do
                    if line:match("^[%s│]*[├└]──") then direct = direct + 1 end
                    if line:match("[%s│]*[├└]──") then nodes = nodes + 1 end
                end
                output = string.format("Direct dependencies: %d · graph entries: %d\n%s", direct, nodes, output)
            end
            show_report(label, output)
        end)
    end)
end

local function outdated(root, filetype)
    local command
    if filetype == "rust" then
        command = { "cargo", "update", "--dry-run" }
    elseif filetype == "python" then
        command = { "uv", "tree", "--outdated" }
    elseif (filetype == "javascript" or filetype == "typescript")
        and vim.fn.filereadable(root .. "/package.json") == 1 then
        local package_manager = vim.fn.filereadable(root .. "/pnpm-lock.yaml") == 1 and "pnpm"
            or (vim.fn.filereadable(root .. "/yarn.lock") == 1 and "yarn" or "npm")
        command = package_manager == "yarn" and { "yarn", "outdated" } or { package_manager, "outdated" }
    end

    if not command then
        vim.notify("No dependency update check is configured for this project", vim.log.levels.WARN, { title = "Project" })
        return
    end
    vim.cmd("botright 15split")
    vim.fn.termopen(command, { cwd = root })
    vim.cmd("startinsert")
end

local function upgrade(root, filetype)
    local command
    if filetype == "rust" then
        command = { "cargo", "update" }
    elseif filetype == "python" then
        command = { "sh", "-lc", "uv lock --upgrade && uv sync" }
    elseif (filetype == "javascript" or filetype == "typescript")
        and vim.fn.filereadable(root .. "/package.json") == 1 then
        local manager = vim.fn.filereadable(root .. "/pnpm-lock.yaml") == 1 and "pnpm"
            or (vim.fn.filereadable(root .. "/yarn.lock") == 1 and "yarn" or "npm")
        command = manager == "yarn" and { "yarn", "upgrade" } or { manager, "update" }
    end

    if not command then
        vim.notify("No dependency update command is configured for this project", vim.log.levels.WARN, { title = "Project" })
        return
    end
    vim.cmd("botright 15split")
    vim.fn.termopen(command, { cwd = root })
    vim.cmd("startinsert")
end

vim.api.nvim_create_user_command("ProjectBuild", function() M.run("build") end, {
    desc = "Build the active language project",
})
vim.api.nvim_create_user_command("ProjectTest", function() M.run("test") end, {
    desc = "Test the active language project",
})
vim.api.nvim_create_user_command("ProjectDependencies", function()
    local root, filetype = root_for(0)
    if root then dependency_graph(root, filetype) end
end, { desc = "Show the active project's dependency graph and count" })
vim.api.nvim_create_user_command("ProjectOutdated", function()
    local root, filetype = root_for(0)
    if root then outdated(root, filetype) end
end, { desc = "Check for outdated project dependencies" })
vim.api.nvim_create_user_command("ProjectUpgrade", function()
    local root, filetype = root_for(0)
    if root then upgrade(root, filetype) end
end, { desc = "Update project dependencies" })

return M
