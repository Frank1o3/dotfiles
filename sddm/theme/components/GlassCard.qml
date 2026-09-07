import QtQuick

import ".."

Rectangle {
    id: root

    property real glassOpacity: 0.55

    radius: Theme.cardRadius

    color: Qt.rgba(Theme.bg.r, Theme.bg.g, Theme.bg.b, glassOpacity)

    border.width: 1

    border.color: Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.8)
}
