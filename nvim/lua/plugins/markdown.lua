return {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown" },
    keys = {
        { "<leader>mm", "<cmd>RenderMarkdown toggle<cr>", desc = "Markdown: toggle rendered view" },
        { "<leader>mp", "<cmd>RenderMarkdown preview<cr>", desc = "Markdown: open rendered preview" },
    },
    opts = {
        completions = { lsp = { enabled = true } },
        heading = { enabled = true, sign = false },
        code = { sign = false },
        pipe_table = { enabled = true, style = "full" },
    },
    config = function(_, opts)
        require("render-markdown").setup(opts)

        local function configure_markdown_buffer()
            vim.opt_local.wrap = true
            vim.opt_local.linebreak = true
            vim.opt_local.spell = false
            vim.opt_local.formatoptions:append({ "c", "r", "o", "n" })
        end

        if vim.bo.filetype == "markdown" then
            configure_markdown_buffer()
        end

        local group = vim.api.nvim_create_augroup("MarkdownEditing", { clear = true })
        vim.api.nvim_create_autocmd("FileType", {
            group = group,
            pattern = "markdown",
            callback = configure_markdown_buffer,
        })
        vim.keymap.set("n", "<leader>us", function()
            vim.wo.spell = not vim.wo.spell
            vim.notify("Spell check " .. (vim.wo.spell and "enabled" or "disabled"), vim.log.levels.INFO)
        end, { desc = "Toggle spell checking" })
    end,
}
