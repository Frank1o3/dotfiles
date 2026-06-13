-- ~/.config/hypr/monitors.lua

local primary_monitor = "DP-3"

-- 1. Secondary monitor positioned to the right
hl.monitor({
	output = "HDMI-A-1",
	mode = "1920x1080@60.00Hz",
	position = "1920x-30",
	scale = 1.0,
	cm = "srgb"
})

-- 2. Primary monitor positioned at 0x0
hl.monitor({
	output = primary_monitor,
	mode = "1920x1200@60Hz",
	position = "0x0",
	scale = 1.0,
	bitdepth = 10,
	cm = "srgb",
})

-- 3. Set Workspace 1 as the default and make it persistent on your primary monitor
hl.workspace_rule({
	workspace = "1",
	monitor = primary_monitor,
	default = true,
	persistent = true,
})

