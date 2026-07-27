return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",

    config = function()
        require("nvim-treesitter").setup()

        require("nvim-treesitter").install({
            "python", "lua", "c", "cpp", "rust",
            "javascript", "typescript", "tsx",
            "json", "yaml", "toml", "markdown", "markdown_inline",
            "bash", "query", "vim", "vimdoc",
        })

        -- Highlighting is now enabled per-buffer via autocmd, not a config table
        vim.api.nvim_create_autocmd("FileType", {
            pattern = {
                "python", "lua", "c", "cpp", "rust",
                "javascript", "typescript", "tsx",
                "json", "yaml", "toml", "markdown",
                "bash", "query", "vim", "help",
            },
            callback = function()
                pcall(vim.treesitter.start)
            end,
        })
    end,
}
