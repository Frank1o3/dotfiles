import QtQuick 2.15

import ".."

Rectangle {
    id: root

    property real glassOpacity: Theme.glassOpacity

    radius: Theme.cardRadius

    color: Qt.rgba(Theme.bg.r, Theme.bg.g, Theme.bg.b, glassOpacity)

    border.width: 1
    border.color: Qt.rgba(1, 1, 1, 0.20)

    // Fluid Glass top highlight streak
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 1
        height: parent.height * 0.40
        radius: parent.radius

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: Qt.rgba(1, 1, 1, 0.16)
            }
            GradientStop {
                position: 0.35
                color: Qt.rgba(1, 1, 1, 0.06)
            }
            GradientStop {
                position: 1.0
                color: Qt.rgba(1, 1, 1, 0.0)
            }
        }
    }

    // Top rim specular bead (sharp crisp 1px light catch on upper glass edge)
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 1
        height: 1
        radius: parent.radius
        color: Qt.rgba(1, 1, 1, 0.35)
    }

    // Subtle inner border for extra edge definition on top of the glass
    Rectangle {
        anchors.fill: parent
        anchors.margins: 1
        color: "transparent"
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.10)
        radius: Math.max(0, parent.radius - 1)
    }
}
