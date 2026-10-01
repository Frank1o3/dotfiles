local map = vim.keymap.set
local opts = { buffer = true, silent = true }

map("n", "<leader>Rp", function()
    vim.cmd.RustLsp("runnables")
end, vim.tbl_extend("force", opts, { desc = "Rust runnables" }))

map("n", "<leader>Rd", function()
    vim.cmd.RustLsp("debuggables")
end, vim.tbl_extend("force", opts, { desc = "Rust debuggables" }))

map("n", "<leader>Rc", function()
    vim.cmd.RustLsp("openCargo")
end, vim.tbl_extend("force", opts, { desc = "Open Cargo.toml" }))

map("n", "<leader>Rg", function()
    vim.cmd.RustLsp("crateGraph")
end, vim.tbl_extend("force", opts, { desc = "Rust crate graph" }))
