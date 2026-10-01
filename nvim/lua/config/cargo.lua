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

local function args_or_default(default_args, args)
    if args and #args > 0 then
        return args
    end
    return vim.deepcopy(default_args)
end

function M.add(dev)
    if not current_root() then
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
    if not current_root() then
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
    if not current_root() then
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
        { label = "check --workspace", args = { "check", "--workspace" } },
        { label = "build --workspace", args = { "build", "--workspace" } },
        { label = "build --workspace --release", args = { "build", "--workspace", "--release" } },
        { label = "test --workspace", args = { "test", "--workspace" } },
        { label = "clippy --workspace --all-targets --all-features", args = { "clippy", "--workspace", "--all-targets", "--all-features" } },
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

local function register(name, default_args)
    vim.api.nvim_create_user_command(name, function(cmd)
        M.run(args_or_default(default_args, vim.split(cmd.args, "%s+", { trimempty = true })))
    end, {
        nargs = "*",
        complete = "file",
    })
end

vim.api.nvim_create_user_command("Cargo", M.menu, {})
vim.api.nvim_create_user_command("CargoAdd", function() M.add(false) end, {})
vim.api.nvim_create_user_command("CargoAddDev", function() M.add(true) end, {})
vim.api.nvim_create_user_command("CargoRemove", M.remove, {})
vim.api.nvim_create_user_command("CargoSearch", M.search, {})

register("CargoCheck", { "check", "--workspace" })
register("CargoBuild", { "build", "--workspace" })
register("CargoBuildRelease", { "build", "--workspace", "--release" })
register("CargoRun", { "run" })
register("CargoRunRelease", { "run", "--release" })
register("CargoTest", { "test", "--workspace" })
register("CargoClippy", { "clippy", "--workspace", "--all-targets", "--all-features" })
register("CargoFmt", { "fmt", "--all" })
register("CargoDoc", { "doc", "--workspace", "--no-deps" })
register("CargoTree", { "tree", "--workspace" })
register("CargoUpdate", { "update" })

return M
