vim.g.mapleader = " "

vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", { desc = "Save file" })

-- =========================================================
-- Smart Close: close split if splits exist; otherwise close buffer.
-- Prevents closing Neovim entirely when you only want to stop editing a file.
-- =========================================================
local function smart_close()
    local wins = vim.tbl_filter(function(w)
        local config = vim.api.nvim_win_get_config(w)
        if config.relative ~= "" then return false end -- ignore floating windows
        local buf = vim.api.nvim_win_get_buf(w)
        local ft = vim.bo[buf].filetype
        return ft ~= "neo-tree" and ft ~= "Outline" and ft ~= "trouble" and ft ~= "toggleterm"
    end, vim.api.nvim_list_wins())

    if #wins > 1 then
        -- There are multiple splits open: close current split
        vim.cmd("close")
    else
        local listed = vim.tbl_filter(function(b)
            return vim.bo[b].buflisted and vim.api.nvim_buf_get_name(b) ~= ""
        end, vim.api.nvim_list_bufs())

        if #listed > 1 then
            Snacks.bufdelete()
        else
            vim.cmd("quit")
        end
    end
end

vim.api.nvim_create_user_command("SmartClose", smart_close, { desc = "Close window or buffer safely" })

-- Window / buffer close mappings
vim.keymap.set("n", "<leader>bd", function() Snacks.bufdelete() end, { desc = "Close buffer" })
vim.keymap.set("n", "<leader>qw", smart_close, { desc = "Close window / buffer" })
vim.keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit Neovim" })
vim.keymap.set("n", "<C-w>c", smart_close, { desc = "Close window / buffer" })
vim.keymap.set("n", "<C-w>q", smart_close, { desc = "Close window / buffer" })

-- Expand :q to :SmartClose so closing a file in a single window switches buffers
-- instead of abruptly killing Neovim. (:qa, :q!, :close work unchanged).
vim.cmd([[
  cnoreabbrev <expr> q (getcmdtype() ==# ':' && getcmdline() ==# 'q') ? 'SmartClose' : 'q'
]])
vim.keymap.set("n", "<leader>f", function()
    require("conform").format({
        async = true,
        lsp_fallback = true,
    })
end, { desc = "Format buffer" })

vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, {
    desc = "Show diagnostic",
})

vim.keymap.set("n", "[d", function()
    vim.diagnostic.jump({
        count = -1,
        float = true,
    })
end, {
    desc = "Previous diagnostic",
})

vim.keymap.set("n", "]d", function()
    vim.diagnostic.jump({
        count = 1,
        float = true,
    })
end, {
    desc = "Next diagnostic",
})

vim.keymap.set("n", "<leader>pi", "<cmd>UvInit<cr>", { desc = "uv: init project here" })
vim.keymap.set("n", "<leader>pa", "<cmd>UvAdd<cr>", { desc = "uv: add package" })
vim.keymap.set("n", "<leader>pd", "<cmd>UvAddDev<cr>", { desc = "uv: add dev package" })
vim.keymap.set("n", "<leader>ps", "<cmd>UvSync<cr>", { desc = "uv: sync" })
vim.keymap.set("n", "<leader>po", "<cmd>UvOutdated<cr>", { desc = "uv: show outdated packages" })
vim.keymap.set("n", "<leader>pu", "<cmd>UvUpgrade<cr>", { desc = "uv: upgrade compatible packages" })
vim.keymap.set("n", "<leader>pD", "<cmd>ProjectDependencies<cr>", { desc = "Project: dependency graph and count" })
vim.keymap.set("n", "<leader>pO", "<cmd>ProjectOutdated<cr>", { desc = "Project: check outdated dependencies" })
vim.keymap.set("n", "<leader>pU", "<cmd>ProjectUpgrade<cr>", { desc = "Project: update dependencies" })
vim.keymap.set("n", "<leader>cb", "<cmd>ProjectBuild<cr>", { desc = "Build active project" })
vim.keymap.set("n", "<leader>ct", "<cmd>ProjectTest<cr>", { desc = "Test active project" })
vim.keymap.set("n", "<leader>cr", "<cmd>ProjectRun<cr>", { desc = "Run frontend dev server" })
vim.keymap.set("n", "<leader>cf", function()
    vim.lsp.buf.code_action({
        context = {
            only = { "source.fixAll.ruff" },
            diagnostics = {},
        },
        apply = true,
    })
end, { desc = "Ruff: fix all" })

-- =========================================================
-- Keyboard-only window / pane navigation (no mouse needed)
-- =========================================================
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Focus window left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Focus window down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Focus window up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Focus window right" })

vim.keymap.set("n", "<leader>|", "<cmd>vsplit<cr>", { desc = "Split vertical" })
vim.keymap.set("n", "<leader>-", "<cmd>split<cr>", { desc = "Split horizontal" })

-- Exit terminal mode without reaching for the mouse or a second terminal
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
