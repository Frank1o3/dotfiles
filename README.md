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

# Installation

Run:

```bash
curl -fsSL https://raw.githubusercontent.com/Frank1o3/dotfiles/main/install.sh | bash
```

---

# Dependencies

Main packages used by the setup:

- hyprland
- hyprpaper
- wallust
- waybar
- kitty
- dunst
- fuzzel

---

# Notes

- Wallpapers are stored in `~/wallpapers`
- Themes are generated dynamically using `wallust`
- `hyprpaper` is managed as a user service