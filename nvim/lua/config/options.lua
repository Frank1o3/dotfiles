vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.termguicolors = true

vim.diagnostic.config({
    virtual_text = {
        prefix = "●",
    },

    signs = true,

    underline = true,

    update_in_insert = false,

    severity_sort = true,

    float = {
        border = "rounded",
        source = true,
    },
})

vim.keymap.set("n", "<leader>uh", function()
    vim.lsp.inlay_hint.enable(
        not vim.lsp.inlay_hint.is_enabled()
    )
end, {
    desc = "Toggle inlay hints",
})
