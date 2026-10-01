# Neovim Rust-first development rice

This is the Neovim replacement inside the Frank1o3 dotfiles rice. The existing Catppuccin/UI layer is kept; the development stack is Rust-first, with C/C++ and CMake as the secondary native stack.

## Requirements

- Neovim 0.12+
- git
- rustup / cargo
- cmake, ninja, clang
- lldb or gdb
- graphviz is optional for Rust crate graphs

On first launch, lazy.nvim installs plugins and Mason installs rust-analyzer, clangd, codelldb, and clang-format.

## Rust

The <leader>r group is the Cargo workflow: run, build, check, test, clippy, fmt, docs, dependency tree, update, add/remove dependencies, crate search, and an action menu.

crates.nvim provides crates.io completion in Cargo.toml, version/feature/dependency popups, dependency updates/upgrades, and links. K inside Cargo.toml shows crate information.

rustaceanvim owns rust-analyzer. The uppercase <leader>R group is reserved for Rust-specific runnables, debuggables, Cargo navigation, and crate graphs.

## C/C++

clangd provides completion, diagnostics, navigation, symbols, formatting integration, and compilation-database awareness. clangd_extensions.nvim adds native clangd actions.

The <leader>m group is the CMake workflow: generate, build, run, debug, test, clean, install, presets, target selection, kit selection, and cache access. CMake generation exports compile_commands.json and soft-links it into the project root. Auto-regeneration on save is disabled to avoid expensive reconfiguration in large projects.

C/C++ DAP uses codelldb. Rust debugging uses rustaceanvim's Cargo target discovery.

## Replacement

The zip archive has a top-level nvim/ directory. Back up the old config, then:

mv ~/.config/nvim ~/.config/nvim.backup.$(date +%Y%m%d-%H%M%S)
unzip nvim-rust-first.zip -d ~/.config
nvim
