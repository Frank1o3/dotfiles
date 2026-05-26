---- AUTOSTART ----

return function(WALLPAPER_DIR)
	---- AUTOSTART ----
	hl.on("hyprland.start", function()
		-- Update dbus/systemd activation environment so launched apps see the new vars
		hl.exec_cmd("dbus-update-activation-environment --systemd --all")

		-- Generate wallust colors
		hl.exec_cmd("wallust run " .. WALLPAPER_DIR .. "/wallpaper.jpg")
		hl.exec_cmd("waybar")
		hl.exec_cmd("dunst")
	end)
end
