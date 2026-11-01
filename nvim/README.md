# Neovim project workspace

This config uses Neovim 0.11 or newer. Start a project with `cd path/to/project && nvim .`.

At startup, ripgrep scans visible and hidden files while honoring `.gitignore` and common generated-directory exclusions. It reports source-language percentages by line count. Languages at or above 5% activate their language server, formatter, parser, and language-specific tools. CMake and data-file support activates whenever those files are present. Use `:ProjectLanguages` to view the report again.

When a directory is opened, Neovim opens its `README.md` if available; otherwise it opens a normal empty buffer. Neo-tree opens as a sidebar and hides Git-ignored files. `<leader>e` toggles the explorer. `<leader>gg` opens LazyGit for commits and other Git operations. Gitsigns shows and stages individual hunks. `<leader>th` and `<leader>tv` open terminals.

| Files | Language support |
| --- | --- |
| Python | Ty workspace diagnostics and navigation; Ruff linting, fixes, import sorting, and formatting; pytest and debugpy |
| Rust | rust-analyzer with Cargo targets, proc macros, Clippy diagnostics, and rustfmt; crates.nvim version and feature actions |
| C and C++ | clangd, clang-tidy diagnostics, clang-format, CMake language server, CMake/Meson/Make/Ninja build and test commands |
| QML | Qt `qmlls` completion and diagnostics, Tree-sitter parsing, and `qmlformat` |
| JavaScript and TypeScript | vtsls and Prettier |
| JSON | jsonls with SchemaStore validation and Prettier |
| YAML | yamlls with SchemaStore schemas and Prettier |
| TOML | Taplo diagnostics, completion, and formatting |

Tree-sitter provides syntax parsing and highlighting alongside language-server diagnostics. In mixed projects, each language at or above the threshold gets its own tooling; C and C++ share one clangd process.

`<leader>cb` runs `:ProjectBuild` and `<leader>ct` runs `:ProjectTest` for the workspace. They run the detected Rust, Python, native, and JavaScript/TypeScript build scripts in sequence when a mixed project contains more than one. Python uses uv where the project has a `pyproject.toml`; Rust uses Cargo; native projects use CMake, Meson, Make, or Ninja. Output appears in a terminal split. CMake builds generate `compile_commands.json` for clangd.

`<leader>pD` opens the dependency tree and count for Cargo, uv, npm/pnpm/Yarn, or the target graph for CMake projects. `<leader>pO` checks for outdated Rust, Python, or JavaScript dependencies; `<leader>pU` applies package-manager updates for those projects. For Python, `<leader>po` shows outdated packages with `uv tree --outdated`, and `<leader>pu` upgrades the lockfile then syncs the environment. For Rust crates, use `<leader>ru` to update the current crate, `<leader>rU` to upgrade it, `<leader>rA` to upgrade all crates, and `<leader>rv` for available versions.

Mason installs only the language tools selected from the startup workspace. Clippy and rustfmt are rustup components; a full `setup.sh` run installs them on stable. QML tooling (`qmlls` and `qmlformat`) comes from `qt6-declarative`. CMake projects can provide QML build metadata for better QML completion and diagnostics.
