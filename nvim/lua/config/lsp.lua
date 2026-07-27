vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(event)
        local opts = { buffer = event.buf }
        local client = vim.lsp.get_client_by_id(event.data.client_id)

        if client and client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(true, {
                bufnr = event.buf,
            })
        end

        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

        vim.keymap.set("n", "<leader>ci", function()
            vim.lsp.buf.code_action({
                context = {
                    only = { "source.organizeImports" },
                    diagnostics = {},
                },
                apply = true,
            })
        end, { buffer = event.buf, desc = "Organize imports" })
    end,
})
