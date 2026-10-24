pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property color glassRim: Qt.rgba(1, 1, 1, 0.25)
    readonly property color glassHighlight: Qt.rgba(1, 1, 1, 0.38)
    readonly property color glassInnerBorder: Qt.rgba(1, 1, 1, 0.12)

    readonly property string wallpaper: adapter.wallpaper
    readonly property string background: adapter.background
    readonly property string foreground: adapter.foreground
    readonly property string cursor: adapter.cursor
    readonly property var palette: adapter.colors  // array, color0..color15

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
