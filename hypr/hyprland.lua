-- ~/.config/hypr/hyprland.lua
-- Dynamic Path Resolution (Portable for Dotfiles Repos)

local HOME = os.getenv("HOME") or "/home/default"
local WALLPAPER_DIR = HOME .. "/wallpapers"

-- Load modules
require("modules.env")
require("modules.misc")
require("modules.monitors")
require("modules.decorations")
require("modules.layer_rules")
require("modules.animations")
require("modules.layout")
require("modules.window_rules")
require("modules.input")
require("modules.keybinds")
require("modules.autostart")(WALLPAPER_DIR)

-- Patch
hl.config({
    quirks = {
        skip_non_kms_dmabuf_formats = false,
    },
    debug = {
        invalidate_buffers = 0,
    },
})
