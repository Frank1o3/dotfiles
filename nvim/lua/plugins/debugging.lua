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

        -- Prefer project-local (uv) venv, then Mason's debugpy venv,
        -- then whatever python3 is on PATH.
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

        dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
        end

        vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
        vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "Continue" })
        vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "Step over" })
        vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step into" })
        vim.keymap.set("n", "<leader>dO", dap.step_out, { desc = "Step out" })
    end,
}
