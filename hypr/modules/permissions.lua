-- Permissions module for Hyprland
-- This module checks if the user has the necessary permissions to run certain commands or access certain files

hl.permission({binary = "{HOME}/.config/hypr/scripts/pick-wallpaper.sh", permissions = {"execute"}})
hl.permission({binary = "{HOME}/.config/hypr/scripts/brightness.sh", permissions = {"execute"}})
hl.permission({binary = "{HOME}/.config/hypr/scripts/power-menu.sh", permissions = {"execute"}})
