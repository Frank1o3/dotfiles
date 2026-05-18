-- ~/.config/hypr/modules/env.lua

return function()
    -- QT Environment Variables\
    hl.env("QT_STYLE_OVERRIDE", "gtk3")
    hl.env("QT_QPA_PLATFORM", "wayland;xcb")

    -- GTK Environment Variables
    hl.env("GTK_THEME", "Adwaita:Dark")
    hl.env("GDK_THEME", "Adwaita:Dark")
    hl.env("GTK_ICON_THEME", "Papirus-Dark")
    hl.env("GTK_CURSOR_THEME", "catppuccin-mocha-dark-cursors")
    hl.env("GTK_APPLICATION_PREFER_DARK_THEME", "1")
    hl.env("GDK_SCALE", "1")

    -- Cursor Size
    hl.env("XCURSOR_SIZE", "20")
    hl.env("HYPRCURSOR_SIZE", "20")
    hl.env("XCURSOR_THEME", "catppuccin-mocha-dark-cursors")
    hl.env("HYPRCURSOR_THEME", "catppuccin-mocha-dark-cursors")


    -- XDG Environment Variables
    hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
    hl.env("XDG_SESSION_TYPE", "wayland")
    hl.env("XDG_SESSION_DESKTOP", "Hyprland")
end
