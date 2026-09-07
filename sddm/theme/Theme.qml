pragma Singleton

import QtQuick

QtObject {
    readonly property color bg: config.colorBackground || "#1e1e2e"

    readonly property color fg: config.colorForeground || "#cdd6f4"

    readonly property color accent: config.colorAccent || "#89b4fa"

    readonly property color border: config.colorBorder || "#313244"

    readonly property color surface: Qt.rgba(bg.r, bg.g, bg.b, 0.62)

    readonly property color input: Qt.rgba(1, 1, 1, 0.08)

    readonly property color inputBorder: Qt.rgba(1, 1, 1, 0.12)

    readonly property color muted: Qt.rgba(fg.r, fg.g, fg.b, 0.65)

    readonly property color error: "#f38ba8"

    readonly property string fontFamily: config.fontFamily || "SpaceMono Nerd Font"

    readonly property int radius: 10

    readonly property int cardRadius: 20
}
