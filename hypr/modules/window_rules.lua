-- ~/.config/hypr/window_rules.lua

hl.window_rule({
	-- Fix some dragging issues with XWayland
	name = "fix-xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},

	no_focus = true,
})

hl.window_rule({
	name = "Picture in Picture",
	match = {
		title = "Picture in Picture",
		initial_title = "Picture in Picture",
	},
	float = true,
	persistent_size = true,
	size = { 426, 240 }, -- 240p or 426x240
})

hl.window_rule({
	-- Ignore maximize requests from all apps. You'll probably like this.
	name = "suppress-maximize-events",
	match = { class = ".*" },

	suppress_event = "maximize",
})


-- Games
hl.window_rule({
	name = "BloodStrike",
	match = { initial_class = "steam_app_3199170" },
	fullscreen = false,
	persistent_size = true,
	size = { 1280, 720 }, -- 720p or 1280x720
	float = true,
	center = true,
})

hl.window_rule({
	name = "Sober",
	match = { initial_class = "org.vinegarhq.Sober" },
	fullscreen = false,
	persistent_size = true,
	size = { 1280, 720 }, -- 720p or 1280x720
	float = true,
	center = true,
})
