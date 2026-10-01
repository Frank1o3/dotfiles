vim.g.mapleader = " "
vim.g.maplocalleader = ","

local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
end

map("n", "<leader>w", "<cmd>write<cr>", "Write buffer")
map("n", "<leader>q", "<cmd>quit<cr>", "Quit window")
map("n", "<leader>f", function()
    require("conform").format({ async = true, lsp_fallback = true })
end, "Format buffer")
map("n", "<leader>d", vim.diagnostic.open_float, "Show diagnostic")

map("n", "[d", function()
    vim.diagnostic.jump({ count = -1, float = true })
end, "Previous diagnostic")
map("n", "]d", function()
    vim.diagnostic.jump({ count = 1, float = true })
end, "Next diagnostic")

map("n", "<leader>sf", "<cmd>Telescope find_files<cr>", "Search files")
map("n", "<leader>sg", "<cmd>Telescope live_grep<cr>", "Search text")
map("n", "<leader>sb", "<cmd>Telescope buffers<cr>", "Search buffers")
map("n", "<leader>ss", "<cmd>Telescope lsp_document_symbols<cr>", "Search symbols")
map("n", "<leader>sd", "<cmd>Telescope diagnostics<cr>", "Search diagnostics")

-- Rust / Cargo.
map("n", "<leader>rr", "<cmd>CargoRun<cr>", "Cargo run")
map("n", "<leader>rR", "<cmd>CargoRunRelease<cr>", "Cargo run release")
map("n", "<leader>rb", "<cmd>CargoBuild<cr>", "Cargo build workspace")
map("n", "<leader>rB", "<cmd>CargoBuildRelease<cr>", "Cargo build release")
map("n", "<leader>rc", "<cmd>CargoCheck<cr>", "Cargo check workspace")
map("n", "<leader>rt", "<cmd>CargoTest<cr>", "Cargo test workspace")
map("n", "<leader>rl", "<cmd>CargoClippy<cr>", "Cargo clippy workspace")
map("n", "<leader>rf", "<cmd>CargoFmt<cr>", "Cargo fmt all")
map("n", "<leader>rd", "<cmd>CargoDoc<cr>", "Cargo docs")
map("n", "<leader>rg", "<cmd>CargoTree<cr>", "Cargo dependency tree")
map("n", "<leader>ru", "<cmd>CargoUpdate<cr>", "Cargo update")
map("n", "<leader>ra", "<cmd>CargoAdd<cr>", "Cargo add dependency")
map("n", "<leader>rA", "<cmd>CargoAddDev<cr>", "Cargo add dev dependency")
map("n", "<leader>rx", "<cmd>CargoRemove<cr>", "Cargo remove dependency")
map("n", "<leader>rs", "<cmd>CargoSearch<cr>", "Search crates.io")
map("n", "<leader>rq", "<cmd>Cargo<cr>", "Cargo action menu")

-- Rust-analyzer / rustaceanvim extras.
map("n", "<leader>Rp", "<cmd>RustLsp runnables<cr>", "Rust runnables")
map("n", "<leader>Rd", "<cmd>RustLsp debuggables<cr>", "Rust debuggables")
map("n", "<leader>Rc", "<cmd>RustLsp openCargo<cr>", "Open Cargo.toml")
map("n", "<leader>Rg", "<cmd>RustLsp crateGraph<cr>", "Rust crate graph")

-- C/C++ and CMake.
map("n", "<leader>mg", "<cmd>CMakeGenerate<cr>", "CMake generate")
map("n", "<leader>mb", "<cmd>CMakeBuild<cr>", "CMake build")
map("n", "<leader>mB", "<cmd>CMakeQuickBuild<cr>", "CMake quick build")
map("n", "<leader>mr", "<cmd>CMakeRun<cr>", "CMake run")
map("n", "<leader>mR", "<cmd>CMakeRunCurrentFile<cr>", "CMake run current target")
map("n", "<leader>md", "<cmd>CMakeDebug<cr>", "CMake debug target")
map("n", "<leader>mD", "<cmd>CMakeDebugCurrentFile<cr>", "CMake debug current target")
map("n", "<leader>mt", "<cmd>CMakeRunTest<cr>", "CMake run test")
map("n", "<leader>mc", "<cmd>CMakeClean<cr>", "CMake clean")
map("n", "<leader>mi", "<cmd>CMakeInstall<cr>", "CMake install")
map("n", "<leader>mp", "<cmd>CMakeSelectConfigurePreset<cr>", "CMake configure preset")
map("n", "<leader>mP", "<cmd>CMakeSelectBuildPreset<cr>", "CMake build preset")
map("n", "<leader>ms", "<cmd>CMakeSelectBuildTarget<cr>", "CMake build target")
map("n", "<leader>mS", "<cmd>CMakeSelectLaunchTarget<cr>", "CMake launch target")
map("n", "<leader>mk", "<cmd>CMakeSelectKit<cr>", "CMake select kit")
map("n", "<leader>mo", "<cmd>CMakeOpenCache<cr>", "Open CMake cache")

-- Debugger.
map("n", "<leader>db", function() require("dap").toggle_breakpoint() end, "Toggle breakpoint")
map("n", "<leader>dc", function() require("dap").continue() end, "Continue")
map("n", "<leader>do", function() require("dap").step_over() end, "Step over")
map("n", "<leader>di", function() require("dap").step_into() end, "Step into")
map("n", "<leader>dO", function() require("dap").step_out() end, "Step out")
map("n", "<leader>dr", function() require("dap").restart() end, "Restart debugger")
map("n", "<leader>dx", function() require("dap").terminate() end, "Terminate debugger")
map("n", "<leader>du", function() require("dapui").toggle() end, "Toggle debugger UI")
map("n", "<leader>de", function() require("dapui").eval() end, "Evaluate expression")

-- Existing Python/UV workflow.
map("n", "<leader>pi", "<cmd>UvInit<cr>", "uv: init project")
map("n", "<leader>pa", "<cmd>UvAdd<cr>", "uv: add package")
map("n", "<leader>pd", "<cmd>UvAddDev<cr>", "uv: add dev package")
map("n", "<leader>ps", "<cmd>UvSync<cr>", "uv: sync")

-- Windows / terminals.
map("n", "<C-h>", "<C-w>h", "Focus window left")
map("n", "<C-j>", "<C-w>j", "Focus window down")
map("n", "<C-k>", "<C-w>k", "Focus window up")
map("n", "<C-l>", "<C-w>l", "Focus window right")
map("n", "<leader>|", "<cmd>vsplit<cr>", "Split vertical")
map("n", "<leader>-", "<cmd>split<cr>", "Split horizontal")
map("t", "<Esc><Esc>", [[<C-><C-n>]], "Exit terminal mode")
