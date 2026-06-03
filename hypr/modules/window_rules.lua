-- ~/.config/hypr/window_rules.lua

-- Set your desired vertical resolution (height).
-- Supported: 480, 540, 720, 1080, etc. The function auto-calculates 16:9 width.
local game_res = 576

-- 🔢 Calculates standard 16:9 width based on the given height
local function calc_resolution(height)
	local width = math.ceil(height * (16 / 9))
	return { width, height }
end

-- Pre-calculate resolution table for the global game rule
local game_size = calc_resolution(game_res)

-- Fix some dragging issues with XWayland
hl.window_rule({
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
	size = { 426, 240 },
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
	match = { initial_class = "^(steam_app_3199170|bloodstrike\\.exe)$" },
	fullscreen = false,
	tag = "game",
})

hl.window_rule({
	name = "Sober",
	match = { initial_class = "org.vinegarhq.Sober" },
	fullscreen = false,
	tag = "game",
})

hl.window_rule({
	name = "Minecraft",
	match = { initial_class = "^Minecraft.*" },
	fullscreen = false,
	tag = "game",
})

-- Global Game rules (OPTIMIZED FOR WAYLAND/VULKAN STABILITY)
hl.window_rule({
	match = { tag = "game" },
	float = true,
	persistent_size = false, -- Prevents size-restoration stalls that trigger Vulkan swapchain recreation
	size = game_size, -- Dynamic 16:9 resolution (auto-calculated from game_res)
	no_anim = true, -- Disables window animations for instant response
	no_blur = true,
	no_dim = true,
	no_vrr = true, -- Keeps frame pacing consistent on 60Hz displays
	immediate = true, -- Allows tearing for lowest input latency
	idle_inhibit = "always", -- Prevents compositor power/state changes mid-match
	workspace = "1",
	border_size = 0, -- Removes compositor border rendering overhead
	rounding = 0, -- Disables rounding to save GPU cycles
})
