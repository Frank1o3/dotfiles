-- ~/.config/hypr/hyprland.lua
-- Dynamic Path Resolution (Portable for Dotfiles Repos)
local HOME = os.getenv("HOME") or "/home/default"
local CONFIG_DIR = HOME .. "/.config/hypr"
local WALLPAPER_DIR = HOME .. "/wallpapers"

-- Load modules
local setupKeybinds = require("modules.keybinds")
local setupAnimations = require("modules.animations")
local setupMonitors = require("modules.monitors")
local setupWindowRules = require("modules.window_rules")

-- Safe wallust colors load
local ok, wallust = pcall(require, "colors")
local w_col = ok and wallust.general and wallust.general.col or {}

---- MY PROGRAMS ----
local terminal = "kitty"
local menu = "fuzzel"
local ide = "code"
local browser = "xdg-open https://"
local fileManager = "xdg-open $HOME"
local mainMod = "SUPER"

---- AUTOSTART ----
hl.on("hyprland.start", function()
	-- GTK / Libadwaita dark mode (set dconf/gsettings first)
	hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme prefer-dark")

	hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark")

	hl.exec_cmd("gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark")

	-- Cursor consistency
	hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme Bibata-Modern-Classic")

	-- Export relevant theme environment variables to the user systemd environment
	-- so autostarted apps and systemd user services inherit them.
	hl.exec_cmd(
	"systemctl --user set-environment GTK_THEME='Adwaita:dark' GDK_THEME='Adwaita:dark' GTK_ICON_THEME='Papirus-Dark' GTK_APPLICATION_PREFER_DARK_THEME='1' QT_QPA_PLATFORMTHEME='qt6ct' QT_STYLE_OVERRIDE='gtk2' XDG_CURRENT_DESKTOP='Hyprland' XDG_SESSION_TYPE='wayland'")

	-- Update dbus/systemd activation environment so launched apps see the new vars
	hl.exec_cmd("dbus-update-activation-environment --systemd --all")

	-- Generate wallust colors
	hl.exec_cmd("wallust run " .. WALLPAPER_DIR .. "/wallpaper.jpg")
end)

hl.config({
	env = {
		"QT_QPA_PLATFORMTHEME=qt6ct",
		"QT_STYLE_OVERRIDE=gtk3",
		"XDG_CURRENT_DESKTOP=Hyprland",
		"XDG_SESSION_TYPE=wayland",

		-- GTK
		"GTK_THEME=Adwaita:dark",
		"GDK_THEME=Adwaita:dark",
		"GTK_ICON_THEME=Papirus-Dark",
		"GTK_APPLICATION_PREFER_DARK_THEME=1",
	},
})

---- LOOK AND FEEL ----
hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 20,
		border_size = 2,
		col = {
			active_border = w_col.active_border or { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
			inactive_border = w_col.inactive_border or "rgba(595959aa)",
		},
		resize_on_border = false,
		allow_tearing = false,
		layout = "dwindle",
	},
	decoration = {
		rounding = 10,
		shadow = { enabled = true, range = 4, color = 0xee1a1a1a },
		blur = { enabled = true, size = 3, passes = 1 },
	},
	animations = { enabled = true },
	cursor = { no_hardware_cursors = 2 },
})

--- MONITORS ---
setupMonitors()

---- MISC ----
hl.config({
	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
	},
})

---- INPUT ----
hl.config({
	input = {
		kb_layout = "us",
		follow_mouse = 1,
		sensitivity = 0,
		touchpad = { natural_scroll = false },
	},
})

---- KEYBINDINGS ----
setupKeybinds(mainMod, terminal, fileManager, menu, ide, browser, CONFIG_DIR)

---- ANIMATIONS/CURVES ----
setupAnimations()

---- WINDOW RULES ----
setupWindowRules()

---- LAYOUTS CONFIG ----
hl.config({
	dwindle = { preserve_split = true },
	master = { new_status = "master" },
	scrolling = { fullscreen_on_one_column = true },
})
