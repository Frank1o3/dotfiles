---- AUTOSTART ----

return function(WALLPAPER_DIR)
	---- AUTOSTART ----
	hl.on("hyprland.start", function()
		-- Update dbus/systemd activation environment so launched apps see the new vars
		hl.exec_cmd("dbus-update-activation-environment --systemd --all")
		hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3-dark")
		hl.exec_cmd("gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark")
		hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme catppuccin-mocha-dark-cursors")

		-- Generate wallust colors
		hl.exec_cmd("wallust run " .. WALLPAPER_DIR .. "/wallpaper.jpg")
		hl.exec_cmd("systemctl --user start waybar swaync")
		hl.exec_cmd("nm-applet --indicator &")
	end)
end
