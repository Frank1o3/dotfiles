-- ~/.config/hypr/keybinds.lua

return function(mainMod, terminal, fileManager, menu, ide, browser, scripts_dir)
	local script_pick = scripts_dir .. "/scripts/pick-wallpaper.sh"
	local script_power = scripts_dir .. "/scripts/power-menu.sh"

	--------------------------------------------------
	-- Applications
	--------------------------------------------------

	hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
	hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))

	hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))

	hl.bind(mainMod .. " + D", hl.dsp.exec_cmd(menu))
	hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))

	hl.bind(mainMod .. " + I", hl.dsp.exec_cmd(ide))

	hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))

	--------------------------------------------------
	-- Window Management
	--------------------------------------------------

	hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close())

	hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = 0 }))

	hl.bind(
		mainMod .. " + SHIFT + F",
		hl.dsp.window.float({
			action = "toggle",
		})
	)

	--------------------------------------------------
	-- Desktop / Session
	--------------------------------------------------

	hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(script_pick))

	hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(script_power))

	hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))

	hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("loginctl lock-session"))

	--------------------------------------------------
	-- Focus Movement (vim + arrows)
	--------------------------------------------------

	local directions = {
		h = "left",
		j = "down",
		k = "up",
		l = "right",
		left = "left",
		right = "right",
		up = "up",
		down = "down",
	}

	for key, dir in pairs(directions) do
		hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ direction = dir }))
	end

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
		"XF86AudioRaiseVolume",
		hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
		{ locked = true, repeating = true }
	)

	hl.bind(
		"XF86AudioLowerVolume",
		hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
		{ locked = true, repeating = true }
	)

	hl.bind(
		"XF86AudioMute",
		hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
		{ locked = true, repeating = true }
	)

	hl.bind(
		"XF86AudioMicMute",
		hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
		{ locked = true, repeating = true }
	)

	--------------------------------------------------
	-- Brightness Controls
	--------------------------------------------------

	hl.bind(
		"XF86MonBrightnessUp",
		hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),
		{ locked = true, repeating = true }
	)

	hl.bind(
		"XF86MonBrightnessDown",
		hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),
		{ locked = true, repeating = true }
	)

	--------------------------------------------------
	-- Media Controls
	--------------------------------------------------

	hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })

	hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

	hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

	hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
end
