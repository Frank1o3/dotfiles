# AGENTS

## Purpose
This repository is a personal Hyprland dotfiles setup. The main focus for AI agents is to safely update configuration scripts and shell utilities, especially Hyprland keybinds and session management.

## Key areas
- `hypr/modules/keybinds.lua` — Hyprland keybinding definitions and script dispatch.
- `hypr/scripts/power-menu.sh` — Power menu implementation that handles sign-out, sleep, hibernate, reboot, shutdown, and lock actions.
- `README.md` — high-level overview of the setup and keybinds.

## Issue context: power menu sign-out
- The power menu is launched from `SUPER + SHIFT + E` and uses `fuzzel` to choose an option.
- The `Sign Out` branch currently runs `hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit`.
- Agents should verify whether `hyprshutdown` is available and whether `hyprctl dispatch exit` is the correct fallback for the user’s Hyprland version.
- If `Sign Out` is broken, prioritize a reproducible fix rather than broad refactoring.

## Agent guidance
- Prefer editing `hypr/scripts/power-menu.sh` for session action behavior.
- Confirm that the action is triggered correctly from `hypr/modules/keybinds.lua` and that no script path or permission issue exists.
- Do not alter unrelated window manager or theme files for this fix.
- Keep changes minimal and test the power menu flow in Hyprland if possible.

## Notes for future AI work
- This repo contains user-specific XDG paths and dotfile conventions; avoid introducing generic Linux defaults without a clear reason.
- The setup relies on `fuzzel`, `hyprctl`, `hyprshutdown`, `hyprlock`/`swaylock`, and `loginctl`.
- Root directory documentation is limited; use `README.md` for general context.

## Recommended next customization
- Create a task-specific skill or prompt for fixing shell-based Hyprland scripts, e.g. `/create-skill fix-power-menu`.
