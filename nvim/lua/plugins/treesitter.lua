return {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",

    config = function()
        require("nvim-treesitter").setup()

        local parsers = require("config.workspace").treesitter_languages()
        local filetypes_by_parser = {
            python = { "python" }, lua = { "lua" }, c = { "c" }, cpp = { "cpp" }, rust = { "rust" },
            javascript = { "javascript", "javascriptreact" }, typescript = { "typescript", "typescriptreact" },
            qmljs = { "qml", "qmljs" }, cmake = { "cmake" }, gitignore = { "gitignore" },
            json = { "json" }, yaml = { "yaml" }, toml = { "toml" },
            markdown = { "markdown" }, markdown_inline = { "markdown" }, bash = { "sh", "bash" },
        }
        local filetypes, seen = { "help" }, { help = true }
        for _, parser in ipairs(parsers) do
            for _, filetype in ipairs(filetypes_by_parser[parser] or {}) do
                if not seen[filetype] then
                    seen[filetype] = true
                    table.insert(filetypes, filetype)
                end
            end
        end

        if #parsers > 0 then
            require("nvim-treesitter").install(parsers)
        end

        vim.api.nvim_create_autocmd("FileType", {
            pattern = filetypes,
            callback = function()
                pcall(vim.treesitter.start)
            end,
        })
    end,
}
