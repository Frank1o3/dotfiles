local M = {}

local project = require("config.project")

local function notify(message, level)
    vim.notify(message, level or vim.log.levels.INFO, { title = "Cargo" })
end

local function current_root()
    local root = project.cargo_root(vim.api.nvim_buf_get_name(0))
    if not root then
        notify("No Cargo.toml found for the current buffer", vim.log.levels.ERROR)
    end
    return root
end

local function shell_title(args)
    return "cargo " .. table.concat(args, " ")
end

function M.run(args, opts)
    opts = opts or {}
    local root = current_root()
    if not root then
        return
    end

    vim.cmd("botright 16split")
    local bufnr = vim.api.nvim_get_current_buf()
    vim.bo[bufnr].bufhidden = "wipe"
    vim.bo[bufnr].filetype = "terminal"
    pcall(vim.api.nvim_buf_set_name, bufnr, "cargo://" .. table.concat(args, "-") .. "-" .. os.time())

    local command = { "cargo" }
    vim.list_extend(command, args)

    vim.fn.termopen(command, {
        cwd = root,
        on_exit = function(_, code)
            vim.schedule(function()
                local level = code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
                notify(shell_title(args) .. " exited with " .. code, level)
            end)
        end,
    })

    if opts.start_insert ~= false then
        vim.cmd.startinsert()
    end
end

function M.add(dev)
    local root = current_root()
    if not root then
        return
    end

    vim.ui.input({
        prompt = dev and "cargo add --dev: " or "cargo add: ",
    }, function(package)
        if not package or vim.trim(package) == "" then
            return
        end

        local args = { "add" }
        if dev then
            table.insert(args, "--dev")
        end
        table.insert(args, vim.trim(package))
        M.run(args)
    end)
end

function M.remove()
    local root = current_root()
    if not root then
        return
    end

    vim.ui.input({ prompt = "cargo remove: " }, function(package)
        if not package or vim.trim(package) == "" then
            return
        end
        M.run({ "remove", vim.trim(package) })
    end)
end

function M.search()
    local root = current_root()
    if not root then
        return
    end

    vim.ui.input({ prompt = "cargo search: " }, function(query)
        if not query or vim.trim(query) == "" then
            return
        end
        M.run({ "search", vim.trim(query) })
    end)
end

function M.menu()
    local actions = {
        { label = "check", args = { "check", "--workspace" } },
        { label = "build (workspace)", args = { "build", "--workspace" } },
        { label = "build --release", args = { "build", "--workspace", "--release" } },
        { label = "test (workspace)", args = { "test", "--workspace" } },
        { label = "clippy (workspace)", args = { "clippy", "--workspace", "--all-targets", "--all-features" } },
        { label = "fmt --all", args = { "fmt", "--all" } },
        { label = "run", args = { "run" } },
        { label = "run --release", args = { "run", "--release" } },
        { label = "doc --workspace", args = { "doc", "--workspace", "--no-deps" } },
        { label = "tree --workspace", args = { "tree", "--workspace" } },
        { label = "update", args = { "update" } },
        { label = "clean", args = { "clean" } },
        { label = "metadata", args = { "metadata", "--format-version", "1" } },
    }

    vim.ui.select(actions, {
        prompt = "Cargo action",
        format_item = function(item)
            return item.label
        end,
    }, function(choice)
        if choice then
            M.run(choice.args)
        end
    end)
end

vim.api.nvim_create_user_command("Cargo", M.menu, {})
vim.api.nvim_create_user_command("CargoAdd", function() M.add(false) end, {})
vim.api.nvim_create_user_command("CargoAddDev", function() M.add(true) end, {})
vim.api.nvim_create_user_command("CargoRemove", M.remove, {})
vim.api.nvim_create_user_command("CargoSearch", M.search, {})
vim.api.nvim_create_user_command("CargoCheck", function() M.run({ "check", "--workspace" }) end, {})
vim.api.nvim_create_user_command("CargoBuild", function() M.run({ "build", "--workspace" }) end, {})
vim.api.nvim_create_user_command("CargoBuildRelease", function() M.run({ "build", "--workspace", "--release" }) end, {})
vim.api.nvim_create_user_command("CargoRun", function() M.run({ "run" }) end, {})
vim.api.nvim_create_user_command("CargoRunRelease", function() M.run({ "run", "--release" }) end, {})
vim.api.nvim_create_user_command("CargoTest", function() M.run({ "test", "--workspace" }) end, {})
vim.api.nvim_create_user_command("CargoClippy", function() M.run({ "clippy", "--workspace", "--all-targets", "--all-features" }) end, {})
vim.api.nvim_create_user_command("CargoFmt", function() M.run({ "fmt", "--all" }) end, {})
vim.api.nvim_create_user_command("CargoDoc", function() M.run({ "doc", "--workspace", "--no-deps" }) end, {})
vim.api.nvim_create_user_command("CargoTree", function() M.run({ "tree", "--workspace" }) end, {})
vim.api.nvim_create_user_command("CargoUpdate", function() M.run({ "update" }) end, {})

return M
