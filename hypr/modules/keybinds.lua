-- ~/.config/hypr/keybinds.lua

local HOME = os.getenv("HOME") or "/home/default"
local CONFIG_DIR = HOME .. "/.config/hypr"

---- MY PROGRAMS ----
local terminal = "kitty"
local menu = "wofi --show drun"
local ide = "code"
local browser = "xdg-open https://google.com"
local fileManager = "xdg-open " .. HOME
local mainMod = "SUPER"

local script_pick = CONFIG_DIR .. "/scripts/pick-wallpaper.sh"
local script_power = CONFIG_DIR .. "/scripts/power-menu.sh"
local script_games = CONFIG_DIR .. "/scripts/wofi-games.sh"
local script_audio = CONFIG_DIR .. "/scripts/toggle-audio.sh"
local script_emoticon = CONFIG_DIR .. "/scripts/emoticon.py"

--------------------------------------------------
-- Applications
--------------------------------------------------

hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))

hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd(script_games))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(script_emoticon))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))

hl.bind(mainMod .. " + I", hl.dsp.exec_cmd(ide))

hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))

--------------------------------------------------
-- Window Management
--------------------------------------------------

hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close())

hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = 0 }))

hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))

--------------------------------------------------
-- Desktop / Session
--------------------------------------------------

hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("kitty --class wallpaper-picker -e " .. script_pick))

hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("kitty --class power-menu -e " .. script_power))

hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))

hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("loginctl lock-session"))

hl.bind(mainMod .. " + n", hl.dsp.exec_cmd("swaync-client -t"))

--------------------------------------------------
-- Focus Movement (vim + arrows)
--------------------------------------------------

local directions = {
	left = "left",
	right = "right",
	up = "up",
	down = "down",
}

for key, dir in pairs(directions) do
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ direction = dir }))
end

hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

--------------------------------------------------
-- Workspace Switching
--------------------------------------------------

for i = 1, 10 do
	local key = i % 10

	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))

	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

--------------------------------------------------
-- Special Workspace
--------------------------------------------------

hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

--------------------------------------------------
-- Workspace Scrolling
--------------------------------------------------

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

--------------------------------------------------
-- Mouse Window Controls
--------------------------------------------------

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

--------------------------------------------------
-- Audio Controls
--------------------------------------------------

hl.bind(
	mainMod .. " + XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)

hl.bind(
	mainMod .. " + XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)

hl.bind(
	mainMod .. " + XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)

hl.bind(
	mainMod .. " + XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)

--------------------------------------------------
-- Brightness Controls
--------------------------------------------------

hl.bind(
	mainMod .. " + XF86MonBrightnessUp",
	hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),
	{ locked = true, repeating = true }
)

hl.bind(
	mainMod .. " + XF86MonBrightnessDown",
	hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),
	{ locked = true, repeating = true }
)

hl.bind("SCROLL_LOCK", hl.dsp.exec_cmd(script_audio), { locked = true })

--------------------------------------------------
-- Media Controls
--------------------------------------------------

hl.bind(mainMod .. " + XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })

hl.bind(mainMod .. " + XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.bind(mainMod .. " + XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

hl.bind(mainMod .. " + XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

-- Media controls using navigation keys + SUPER

hl.bind(mainMod .. " + HOME", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.bind(mainMod .. " + END", hl.dsp.exec_cmd("playerctl next"), { locked = true })

hl.bind(mainMod .. " + PRIOR", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

hl.bind(mainMod .. " + NEXT", hl.dsp.exec_cmd("playerctl stop"), { locked = true })


--------------------------------------------------
-- Screen Shot
--------------------------------------------------
hl.bind("Print", hl.dsp.exec_cmd("grimblast --notify copy area"))
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("grimblast --notify copy active"))