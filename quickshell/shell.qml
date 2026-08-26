import Quickshell
import QtQuick
import qs.config
import qs.modules.bar
import qs.modules.launcher
import qs.modules.panel
import qs.modules.notifications
import qs.modules.wallpaper

ShellRoot {
    Bar {}
    Launcher {}
    ControlCenter {}
    Toasts {}
    WallpaperPicker {}
}
