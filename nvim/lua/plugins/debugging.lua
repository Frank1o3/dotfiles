return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "mfussenegger/nvim-dap-python",
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
        "mason-org/mason.nvim",
    },
    config = function()
        local dap = require("dap")
        local dapui = require("dapui")

        local function resolve_python()
            local cwd = vim.fn.getcwd()
            local venv_python = cwd .. "/.venv/bin/python"
            if vim.fn.executable(venv_python) == 1 then
                return venv_python
            end

            local mason_python = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
            if vim.fn.executable(mason_python) == 1 then
                return mason_python
            end

            return vim.fn.exepath("python3") or "python3"
        end

        require("dap-python").setup(resolve_python())
        dapui.setup()

        local mason_codelldb = vim.fn.stdpath("data") .. "/mason/bin/codelldb"
        local codelldb = vim.fn.executable(mason_codelldb) == 1 and mason_codelldb or "codelldb"
        local dap_port = "$" .. "{port}"

        dap.adapters.codelldb = {
            type = "server",
            port = dap_port,
            executable = {
                command = codelldb,
                args = { "--port", dap_port },
            },
        }

        local cpp = {
            name = "Launch C/C++ executable",
            type = "codelldb",
            request = "launch",
            program = function()
                local default = vim.fn.getcwd() .. "/build/"
                return vim.fn.input("Executable: ", default, "file")
            end,
            cwd = vim.fn.getcwd(),
            stopOnEntry = false,
            runInTerminal = true,
        }

        dap.configurations.cpp = { cpp }
        dap.configurations.c = { vim.deepcopy(cpp) }
        dap.configurations.objcpp = { vim.deepcopy(cpp) }
        dap.configurations.objc = { vim.deepcopy(cpp) }

        dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
        end
    end,
}
