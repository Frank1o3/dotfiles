local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        lazyrepo,
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)

require("lua.config.options")
require("lua.config.keymaps")
require("lua.config.lsp")
require("lua.config.autocmds")

require("lazy").setup({
    spec = {
        { import = "plugins" },
    },

    checker = {
        enabled = false,
    },

    change_detection = {
        enabled = true,
        notify = false,
    },

    performance = {
        rtp = {
            disabled_plugins = {
                "gzip",
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
})