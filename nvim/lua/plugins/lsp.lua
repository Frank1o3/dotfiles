return {
    "neovim/nvim-lspconfig",

    config = function()
        vim.lsp.config("ty", {
            cmd = { "ty", "server" },
            capabilities = require("blink.cmp").get_lsp_capabilities(),
        })

        vim.lsp.enable("ty")
    end,
}