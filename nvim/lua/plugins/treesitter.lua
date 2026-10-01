return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter").setup()

        require("nvim-treesitter").install({
            "rust", "c", "cpp", "cmake", "toml",
            "python", "lua",
            "javascript", "typescript", "tsx",
            "json", "yaml", "markdown", "markdown_inline",
            "bash", "query", "vim", "vimdoc",
        })

        vim.api.nvim_create_autocmd("FileType", {
            pattern = {
                "rust", "c", "cpp", "objc", "objcpp", "cmake", "toml",
                "python", "lua",
                "javascript", "typescript", "tsx",
                "json", "yaml", "markdown",
                "bash", "query", "vim", "help",
            },
            callback = function()
                pcall(vim.treesitter.start)
            end,
        })
    end,
}
