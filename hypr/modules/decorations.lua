-- Safe wallust colors load
local ok, wallust = pcall(require, "colors")
local w_col = ok and wallust.general and wallust.general.col or {}
local HOME = os.getenv("HOME") or "/home/franklin"

---- LOOK AND FEEL: FLUID GLASS ----
hl.config({
	general = {
		gaps_in = 6,
		gaps_out = 14,
		border_size = 2,
		col = {
			active_border = w_col.active_border or { colors = { "rgba(ffffff55)", "rgba(ffffff22)" }, angle = 45 },
			inactive_border = w_col.inactive_border or "rgba(ffffff15)",
		},
		resize_on_border = false,
		allow_tearing = true,
	},
	decoration = {
		rounding = 14,
		rounding_power = 2,
		active_opacity = 0.88,
		inactive_opacity = 0.78,
		fullscreen_opacity = 1.0,
		shadow = {
			enabled = true,
			range = 25,
			render_power = 3,
			color = "0x8c000000",
			color_inactive = "0x59000000",
			offset = { 0, 4 },
			scale = 1.0,
		},
		blur = {
			enabled = true,
			size = 10,
			passes = 4,
			noise = 0.015,
			contrast = 0.92,
			brightness = 0.82,
			vibrancy = 0.20,
			vibrancy_darkness = 0.15,
			popups = true,
			popups_ignorealpha = 0.6,
			new_optimizations = true,
			xray = false,
		},
		screen_shader = HOME .. "/.config/hypr/shaders/glass-tint.frag",
	},
	animations = { enabled = true },
	cursor = { no_hardware_cursors = 2 },
})
