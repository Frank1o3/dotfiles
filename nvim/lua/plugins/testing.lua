return {
    "nvim-neotest/neotest",
    cond = function() return require("config.workspace").has("Python") end,
    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "nvim-neotest/neotest-python",
    },

    config = function()
        require("neotest").setup({
            adapters = {
                require("neotest-python")({
                    dap = { justMyCode = false },
                    runner = "pytest",
                }),
            },
        })

        local neotest = require("neotest")

        vim.keymap.set("n", "<leader>tn", function() neotest.run.run() end, { desc = "Run nearest test" })
        vim.keymap.set("n", "<leader>tf", function() neotest.run.run(vim.fn.expand("%")) end, { desc = "Run file" })
        vim.keymap.set("n", "<leader>ts", function() neotest.run.run(vim.fn.getcwd()) end, { desc = "Run suite" })
        vim.keymap.set("n", "<leader>to", function() neotest.output.open({ enter = true }) end, { desc = "Test output" })
        vim.keymap.set("n", "<leader>td", function() neotest.run.run({ strategy = "dap" }) end, { desc = "Debug nearest test" })
    end,
}
