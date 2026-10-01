vim.g.rustaceanvim = {
    server = {
        default_settings = {
            ["rust-analyzer"] = {
                cargo = {
                    allFeatures = true,
                },
                procMacro = {
                    enable = true,
                },
                diagnostics = {
                    enable = true,
                },
            },
        },
    },
}

vim.api.nvim_create_autocmd("BufRead", {
    pattern = "*/Cargo.toml",
    callback = function(args)
        vim.keymap.set("n", "K", function()
            local crates = require("crates")
            if crates.popup_available() then
                crates.show_popup()
            else
                vim.lsp.buf.hover()
            end
        end, {
            buffer = args.buf,
            silent = true,
            desc = "Crate information",
        })
    end,
})
