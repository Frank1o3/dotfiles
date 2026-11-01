# Neovim quick reference

Leader is **Space**. Press `Space` and pause to see available shortcuts through which-key.

## Basic editing

| Keys | Action |
| --- | --- |
| `i` / `a` | Insert before / after the cursor |
| `Esc` | Return to Normal mode |
| `v` / `V` | Select characters / lines |
| `d` / `y` / `p` | Delete (cut) / yank (copy) / paste |
| `u` / `Ctrl-r` | Undo / redo |
| `:w` / `:wq` | Save / save and quit |
| `:q` | Smart close (closes split or buffer; exits on last file) |
| `:qa` | Quit all files and exit Neovim |
| `Space w` | Save current file |
| `Space bd` / `Space c` | Close current buffer/file without closing window |
| `Space qw` / `Ctrl-w c` | Close current window or buffer safely |
| `Space qq` | Quit Neovim (all windows) |
| `/text` then `n` / `N` | Search forward, then next / previous match |
| `:%s/old/new/g` | Replace throughout the current file |

## Files and windows

| Keys | Action |
| --- | --- |
| `Space e` | Toggle the file explorer |
| `Space gg` | Open LazyGit for commits, branches, and diffs |
| `Space th` / `Space tv` | Open horizontal / vertical terminal |
| `Ctrl-h/j/k/l` | Move between windows |
| `Space |` / `Space -` | Split vertically / horizontally |
| `Esc Esc` | Leave terminal input mode |

## Code and project

| Keys | Action |
| --- | --- |
| `Space f` | Format the current file |
| `gd` / `gr` / `K` | Go to definition / references / hover documentation |
| `Space rn` / `Space ca` | Rename symbol / code action |
| `Space ce` | Apply ESLint fixes (JavaScript/TypeScript) |
| `[d` / `]d` | Previous / next diagnostic |
| `Space d` | Show diagnostic details |
| `Space cb` / `Space ct` | Build / test detected workspace projects |
| `Space cr` | Run the frontend `dev` / `start` script |
| `Space pD` / `Space pO` / `Space pU` | Dependency tree and count / check outdated / update |
| `:ProjectLanguages` | Show detected language percentages |
| `:ProjectRescan` | Recount languages and refresh language servers |

## Markdown

| Keys | Action |
| --- | --- |
| `Space mm` | Toggle rendered Markdown view |
| `Space mp` | Open rendered Markdown preview |
| `Space us` | Toggle spell checking in this window |

More project and language-specific commands are in [README.md](README.md).
