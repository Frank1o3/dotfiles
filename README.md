# Hyprland Dotfiles

A modern Hyprland setup focused on dynamic wallpaper-based theming, clean visuals, and a minimal workflow.

The rice uses `wallust` to generate full desktop color themes from your current wallpaper and automatically applies them across:
- Waybar
- Kitty
- Dunst
- Fuzzel
- Hyprland

It also includes:
- wallpaper selector (`SUPER + W`)
- dynamic recoloring
- Hyprpaper integration
- modular Hyprland configuration
- automated installation script

---

# Goals

- Refine the Waybar design and layout
- Add smoother theme transition animations
- Improve desktop integration and keyring support
- Create a cleaner and more intuitive hotkey layout
- Keep the setup lightweight and maintainable

---

# Modpack para los bacanos
```bash
wget -O modpack.mrpack http://cloud-mc.duckdns.org:8080/modpack.mrpack
```

# Installation

Run:

```bash
curl -fsSL https://raw.githubusercontent.com/Frank1o3/dotfiles/refs/heads/main/setup.sh | bash
```

---

# Update Config
If you want you'r configs to stay up to date with the updates i make you can Run:

(bash & zsh) Terminal's:
```bash
curl -fsSL https://raw.githubusercontent.com/Frank1o3/dotfiles/rmain/update-config.py | python3
```

fish Terminal:
```bash
python3 (curl -fsSL https://raw.githubusercontent.com/Frank1o3/dotfiles/main/update-config.py | psub)
```

---


# Dependencies

Main packages used by the setup:

- hyprland
- hyprpaper
- wallust
- waybar
- kitty
- swaync
- fuzzel

---

# Notes

- Wallpapers are stored in `~/wallpapers`
- Themes are generated dynamically using `wallust`
- `hyprpaper` is managed as a user service

# Keybinds

## Applications

| Keybind | Action |
|---|---|
| `SUPER + Q` | Open terminal |
| `SUPER + RETURN` | Open terminal |
| `SUPER + E` | Open home directory using the system default file manager |
| `SUPER + D` | Open app launcher |
| `SUPER + SPACE` | Open app launcher |
| `SUPER + I` | Open IDE |
| `SUPER + B` | Open default browser |

---

## Desktop & Session

| Keybind | Action |
|---|---|
| `SUPER + W` | Open wallpaper/theme selector |
| `SUPER + SHIFT + E` | Open power menu |
| `SUPER + SHIFT + R` | Reload Hyprland configuration |
| `SUPER + SHIFT + L` | Lock session |

---

## Window Management

| Keybind | Action |
|---|---|
| `SUPER + SHIFT + Q` | Close focused window |
| `SUPER + F` | Toggle fullscreen |
| `SUPER + SHIFT + F` | Toggle floating mode |

---

## Window Navigation

### Arrow Keys

| Keybind | Action |
|---|---|
| `SUPER + ←` | Focus left window |
| `SUPER + →` | Focus right window |
| `SUPER + ↑` | Focus upper window |
| `SUPER + ↓` | Focus lower window |

### Vim-Style Navigation

| Keybind | Action |
|---|---|
| `SUPER + H` | Focus left window |
| `SUPER + J` | Focus lower window |
| `SUPER + K` | Focus upper window |
| `SUPER + L` | Focus right window |

---

## Workspaces

| Keybind | Action |
|---|---|
| `SUPER + 1-0` | Switch workspace |
| `SUPER + SHIFT + 1-0` | Move focused window to workspace |

---

## Special Workspace

| Keybind | Action |
|---|---|
| `SUPER + S` | Toggle special workspace |
| `SUPER + SHIFT + S` | Move window to special workspace |

---

## Mouse Controls

| Keybind | Action |
|---|---|
| `SUPER + Left Mouse` | Drag window |
| `SUPER + Right Mouse` | Resize window |
| `SUPER + Mouse Wheel Up` | Previous workspace |
| `SUPER + Mouse Wheel Down` | Next workspace |

---

## Media Controls

| Keybind | Action |
|---|---|
| `XF86AudioRaiseVolume` | Increase volume |
| `XF86AudioLowerVolume` | Decrease volume |
| `XF86AudioMute` | Toggle audio mute |
| `XF86AudioMicMute` | Toggle microphone mute |
| `XF86AudioNext` | Next track |
| `XF86AudioPrev` | Previous track |
| `XF86AudioPlay` | Play/Pause media |
| `XF86AudioPause` | Play/Pause media |

---

## Brightness Controls

| Keybind | Action |
|---|---|
| `XF86MonBrightnessUp` | Increase brightness |
| `XF86MonBrightnessDown` | Decrease brightness |
