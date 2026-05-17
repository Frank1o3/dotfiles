-- ~/.config/hypr/modules/env.lua

return function()
    -- QT Environment Variables
    hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
    hl.env("QT_STYLE_OVERRIDE", "gtk3")
    hl.env("QT_QPA_PLATFORM", "wayland;xcb")

    -- GTK Environment Variables
    hl.env("GTK_THEME", "Adwaita:dark")
    hl.env("GDK_THEME", "Adwaita:dark")
    hl.env("GTK_ICON_THEME", "Papirus-Dark")
    hl.env("GTK_APPLICATION_PREFER_DARK_THEME", "1")
    hl.env("GDK_SCALE", "2")

    -- Cursor Size
    hl.env("XCURSOR_SIZE", "24")
    hl.env("HYPRCURSOR_SIZE", "24")


    -- XDG Environment Variables
    hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
    hl.env("XDG_SESSION_TYPE", "wayland")
    hl.env("XDG_SESSION_DESKTOP", "Hyprland")
end
