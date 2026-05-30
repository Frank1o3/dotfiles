-- ~/.config/hypr/hyprland.lua
-- Dynamic Path Resolution (Portable for Dotfiles Repos)

local HOME = os.getenv("HOME") or "/home/default"
local CONFIG_DIR = HOME .. "/.config/hypr"
local WALLPAPER_DIR = HOME .. "/wallpapers"

-- Load modules
local setupKeybinds = require("modules.keybinds")
require("modules.env")
require("modules.misc")
require("modules.monitors")
require("modules.decorations")
require("modules.layout")
require("modules.window_rules")
require("modules.input")
require("modules.permissions")
require("modules.autostart")(WALLPAPER_DIR)
