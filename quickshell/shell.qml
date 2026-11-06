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
import qs.modules.cheatsheet
import qs.modules.polkit
import qs.modules.lockscreen
import qs.modules.desktop

ShellRoot {
    Bar {}
    Launcher {}
    Toasts {}
    WallpaperPicker {}
    PowerMenu {}
    Cheatsheet {}
    PolkitDialog {}
    LockScreen {}
    DesktopHud {}
}
