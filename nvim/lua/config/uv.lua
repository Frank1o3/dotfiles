local M = {}

local function notify(msg, level)
    vim.notify(msg, level or vim.log.levels.INFO, { title = "uv" })
end

local function run(cmd, cwd, on_success)
    vim.fn.jobstart(cmd, {
        cwd = cwd,
        on_exit = function(_, code)
            if code == 0 then
                notify(table.concat(cmd, " ") .. " ✔")
                if on_success then on_success() end
            else
                notify(table.concat(cmd, " ") .. " failed (exit " .. code .. ")", vim.log.levels.ERROR)
            end
        end,
    })
end

function M.init_project()
    local cwd = vim.fn.getcwd()
    if vim.fn.filereadable(cwd .. "/pyproject.toml") == 1 then
        notify("pyproject.toml already exists here", vim.log.levels.WARN)
        return
    end
    vim.ui.input({ prompt = "Python version (blank = default): " }, function(pyver)
        local cmd = { "uv", "init", "--no-readme" }
        if pyver and pyver ~= "" then
            vim.list_extend(cmd, { "--python", pyver })
        end
        run(cmd, cwd, function()
            run({ "uv", "add", "--dev", "ruff", "ty", "pytest" }, cwd, function()
                run({ "uv", "sync" }, cwd, function()
                    notify("Project ready — run :LspRestart to pick up the new venv")
                end)
            end)
        end)
    end)
end

function M.add(dev)
    vim.ui.input({ prompt = dev and "uv add --dev: " or "uv add: " }, function(pkg)
        if not pkg or pkg == "" then return end
        local cmd = { "uv", "add", pkg }
        if dev then table.insert(cmd, 2, "--dev") end
        run(cmd, vim.fn.getcwd())
    end)
end

function M.sync() run({ "uv", "sync" }, vim.fn.getcwd()) end

vim.api.nvim_create_user_command("UvInit", M.init_project, {})
vim.api.nvim_create_user_command("UvAdd", function() M.add(false) end, {})
vim.api.nvim_create_user_command("UvAddDev", function() M.add(true) end, {})
vim.api.nvim_create_user_command("UvSync", M.sync, {})

return M
