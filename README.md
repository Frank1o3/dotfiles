# Hyprland Dotfiles

A personal Linux desktop setup built around Hyprland, Quickshell,
and dynamic wallpaper-based theming.

This repo is not a generic dotfiles dump. It is a focused desktop
rice designed to feel modern, fast, and polished: glassy panels,
modular Hyprland config, a compact QuickShell bar, wallpaper-driven
color generation, and a control center that feels more like a desktop
shell than a utility panel.

---

## What this repo includes

- Hyprland window manager configuration with modular Lua files
- Quickshell-based top bar and desktop widgets
- Dynamic palette generation with `wallust`
- Wallpaper picker and wallpaper-driven recoloring
- Launcher, notification surface, power menu, and control center
- Modular setup for status widgets, keybinds, layouts, animations,
  and rules
- A small collection of custom scripts for wallpaper, audio,
  gaming, and desktop actions

This setup is intentionally tuned for a glassy,
low-visual-noise aesthetic while keeping the workflow practical and
keyboard-driven.

---

## Current design direction

The repo now centers around:

- Hyprland for window management
- Quickshell for the desktop shell, bar, panels, and widgets
- `wallust` for live palette generation from wallpaper
- `kitty` as the terminal
- `hypridle`, `hyprlock`, and related session tools for
  lock/suspend workflows

It is a modern desktop rice with focus on:

- elegant glassmorphism panels
- dynamic color consistency across the desktop
- efficient workspaces and window movement
- minimal but usable desktop controls
- maintainable modular config structure

---

## Repository layout

```text
.
├── hypr/                 # Hyprland config and modules
├── quickshell/           # QuickShell shell, bar, widgets, and panels
├── kitty/                # Kitty terminal config
├── fish/                 # Fish config
├── wallpapers/           # Local wallpaper collection
├── wallust/              # Wallust templates and theme config
├── sddm/                 # SDDM theme sync assets
├── setup.sh              # install/bootstrap script
├── sync-config.py        # config sync helper
├── update-config.py      # update helper
├── packages.txt          # package list
├── README.md             # project docs
└── release.py            # release/update helper
```

---

## Installation

Run the install script from the project root or from a
remote source:

```bash
curl -fsSL https://raw.githubusercontent.com/Frank1o3/dotfiles/refs/heads/main/setup.sh | bash
```

If you already cloned the repo locally, you can also run:

```bash
./setup.sh
```

---

## Updating your config

To pull the latest repo updates into your current config
setup:

### bash / zsh

```bash
curl -fsSL https://raw.githubusercontent.com/Frank1o3/dotfiles/main/update-config.py | python3
```

### fish

```bash
python3 (curl -fsSL \
  https://raw.githubusercontent.com/Frank1o3/dotfiles/main/update-config.py \
  | psub)
```

---

## Core dependencies

Main tools used by this setup:

- hyprland
- quickshell
- wallust
- kitty
- hypridle
- hyprlock
- hyprpaper
- nmcli / NetworkManager
- brightnessctl
- swaync / notification stack (as applicable)
- fuzzel or launcher integrations where used

---

## Useful notes

- Wallpapers live in `~/wallpapers`
- Theme colors are generated from wallpaper using `wallust`
- QuickShell and Hyprland are configured as a cohesive desktop shell
- The config is intentionally split into modular files for easier editing and maintenance

---

## Keybinds

### Application launch

| Keybind | Action |
| --- | --- |
| `SUPER + Q` | Launch terminal |
| `SUPER + RETURN` | Launch terminal |
| `SUPER + E` | Open file manager |
| `SUPER + D` | Open launcher |
| `SUPER + A` | Open launcher |
| `SUPER + SPACE` | Open launcher |
| `SUPER + I` | Open IDE |
| `SUPER + B` | Open browser |
| `SUPER + G` | Open game launcher helper |
| `SUPER + M` | Open emoticon picker |

### Desktop and session

| Keybind | Action |
| --- | --- |
| `SUPER + W` | Open wallpaper selector |
| `SUPER + N` | Toggle notifications panel |
| `SUPER + SHIFT + E` | Open power menu |
| `SUPER + SHIFT + R` | Reload Hyprland config |
| `SUPER + SHIFT + L` | Lock session |

### Window management

| Keybind | Action |
| --- | --- |
| `SUPER + SHIFT + Q` | Close active window |
| `SUPER + F` | Toggle fullscreen |
| `SUPER + SHIFT + F` | Toggle floating mode |
| `SUPER + P` | Toggle pseudo mode |
| `SUPER + J` | Toggle split layout |
| `ALT + TAB` | Focus next window |
| `ALT + SHIFT + TAB` | Focus previous window |

### Navigation

| Keybind | Action |
| --- | --- |
| `SUPER + H` | Focus left |
| `SUPER + J` | Focus down |
| `SUPER + K` | Focus up |
| `SUPER + L` | Focus right |
| `SUPER + SHIFT + H` | Move window left |
| `SUPER + SHIFT + J` | Move window down |
| `SUPER + SHIFT + K` | Move window up |
| `SUPER + SHIFT + L` | Move window right |

### Workspaces

| Keybind | Action |
| --- | --- |
| `SUPER + 1-0` | Switch to workspace |
| `SUPER + SHIFT + 1-0` | Move window to workspace |
| `SUPER + S` | Toggle special workspace |
| `SUPER + SHIFT + S` | Move window to special workspace |

---

## Goals of this repo

This repository is meant to be a usable personal rice that is:

- visually modern and consistent
- modular enough to maintain over time
- comfortable for daily desktop use
- tuned around a Linux workflow rather than a generic “theme pack” idea

It is evolving as a more complete desktop environment than the older README suggested.

---

## Notes

This README reflects the current state of the repo, which is built
around a Quickshell-based desktop shell rather than a legacy
Waybar-only layout. If something in the repo feels older than this
document, it is usually a leftover artifact that should be cleaned up
over time as the setup matures.
