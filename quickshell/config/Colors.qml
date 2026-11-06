pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string wallpaper: adapter.wallpaper
    readonly property string background: adapter.background
    readonly property string foreground: adapter.foreground
    readonly property string cursor: adapter.cursor
    readonly property var palette: adapter.colors

    // Shared surfaces derive from the active wallpaper palette so overlays
    // feel related without letting every panel become a different accent wash.
    readonly property color surface: Qt.rgba(backgroundColor.r * 0.72, backgroundColor.g * 0.72, backgroundColor.b * 0.72, 1)
    readonly property color surfaceRaised: Qt.rgba(backgroundColor.r * 0.88, backgroundColor.g * 0.88, backgroundColor.b * 0.88, 1)
    readonly property color surfaceSubtle: Qt.rgba(foregroundColor.r, foregroundColor.g, foregroundColor.b, 0.055)
    readonly property color surfaceHover: Qt.rgba(foregroundColor.r, foregroundColor.g, foregroundColor.b, 0.095)
    readonly property color outline: Qt.rgba(foregroundColor.r, foregroundColor.g, foregroundColor.b, 0.11)
    readonly property color outlineStrong: Qt.rgba(foregroundColor.r, foregroundColor.g, foregroundColor.b, 0.17)
    readonly property color divider: Qt.rgba(foregroundColor.r, foregroundColor.g, foregroundColor.b, 0.09)
    readonly property color accentSurface: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.14)
    readonly property color accentOutline: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.32)
    readonly property color accentColor: color(4)
    readonly property color danger: "#f38ba8"

    readonly property color backgroundColor: adapter.background
    readonly property color foregroundColor: adapter.foreground
    readonly property color textMain: foregroundColor
    readonly property color textMuted: Qt.rgba(foregroundColor.r, foregroundColor.g, foregroundColor.b, 0.74)
    readonly property color textDim: Qt.rgba(foregroundColor.r, foregroundColor.g, foregroundColor.b, 0.48)

    function color(i) {
        return (adapter.colors && adapter.colors[i]) ? adapter.colors[i] : "#ffffff";
    }

    FileView {
        path: `${Quickshell.env("HOME")}/.config/quickshell/colors.json`
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: adapter
            property string wallpaper: ""
            property string background: "#1e1e2e"
            property string foreground: "#cdd6f4"
            property string cursor: "#f5e0dc"
            property var colors: []
        }
    }
}
