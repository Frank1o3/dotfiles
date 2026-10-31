//@ pragma UseQApplication

import Quickshell
import QtQuick
import qs.config
import qs.modules.bar
import qs.modules.launcher
import qs.modules.notifications
import qs.modules.wallpaper
import qs.modules.powermenu
import qs.modules.panel

ShellRoot {
    Bar {}
    Launcher {}
    Toasts {}
    WallpaperPicker {}
    PowerMenu {}
}
