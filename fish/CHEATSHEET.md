# Fish cheat sheet

Shortcuts in this setup are Fish functions. Fish runs the shortcut you type
directly; it does not expand the command line into a different command first.
Arguments after a shortcut are passed to the underlying tool.

## Files and directories

| Shortcut | Action |
| --- | --- |
| `l [path]` | List entries |
| `ll [path]` | Long listing with git status |
| `la [path]` | Include hidden entries |
| `lla [path]` | Long listing including hidden entries |
| `lg`, `llg`, `lag`, `llag` | Matching views that respect git ignore rules |
| `lt [path]` | Tree view |
| `lta`, `ltg`, `ltag` | Tree views: hidden, git ignored, or both |
| `md DIR` | Create directories (`mkdir -p`) |
| `mkcd DIR` | Create and enter a directory |
| `up [N]` | Go up N directories (default 1) |
| `cls` | Clear screen and scrollback |
| Type a directory path and press Enter | Change to that directory directly |
| Type a `.py` path and press Enter | Run it with the nearest project venv, activating that venv in this shell |
| Type an executable path and press Enter | Run it |
| Type a non-executable `.sh` path and press Enter | Show a `chmod +x` instruction without changing permissions |
| Type another text file path and press Enter | View it with `bat`, or open it in the editor |

`eza` is used when installed; otherwise listing shortcuts use `ls`, and tree
shortcuts use `tree` when available.

## Git

| Shortcut | Action |
| --- | --- |
| `gs` | `git status -sb` |
| `ga PATH...` / `gaa` | Add paths / add all changes |
| `gc [args...]` / `gcm MESSAGE` | Commit / commit with message |
| `gp [args...]` / `gpl [args...]` | Push / pull |
| `gd [args...]` / `gds [args...]` | Diff / staged diff |
| `gb [args...]` | Branches |
| `gsw BRANCH` / `gco [args...]` | Switch / checkout |
| `gst [args...]` / `gstp` | Stash / pop stash |
| `gl` / `glog` | Recent graph log / full graph log |

## Packages (Arch)

`paru` is preferred when installed; otherwise install and remove shortcuts use
`sudo pacman`. Search and info shortcuts use the non-privileged `pacman` query.

| Shortcut | Action |
| --- | --- |
| `p [args...]` | Package manager command |
| `psyu` | Sync and upgrade system |
| `pin PACKAGE...` | Install packages |
| `prem PACKAGE...` | Remove packages and unused dependencies |
| `pss QUERY` / `psi PACKAGE` | Search / package info |
| `pclean` | Clean package cache |

## Services and shell

| Shortcut | Action |
| --- | --- |
| `sc [args...]` / `scu [args...]` | System / user `systemctl` |
| `jc [args...]` / `jcu [args...]` | System / user journal (`-xe`) |
| `v [path]` | Open editor (`nvim`, `vim`, or `vi`) |
| `reload` | Restart Fish |
| `venv` | Activate `.venv` or `venv` in the current directory |
| `hclear` / `hclear-session` | Clear saved history / current session history |

Other interactive features: `Ctrl+R` searches history, `Ctrl+T` inserts a
fuzzy-selected file, and `Alt+C` changes to a fuzzy-selected directory when
`fzf` is installed. When `zoxide` is installed, its `z QUERY` command provides
fuzzy directory jumping.
