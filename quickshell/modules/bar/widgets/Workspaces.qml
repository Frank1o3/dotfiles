import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.config

RowLayout {
    id: root
    spacing: 8

    // App Launcher icon
    Rectangle {
        id: launcherBtn
        implicitWidth: 24
        implicitHeight: 24
        radius: 12
        color: launcherMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(1, 1, 1, 0.08)
        border.width: 1
        border.color: launcherMouse.containsMouse ? Colors.color(4) : Qt.rgba(1, 1, 1, 0.14)

        Text {
            anchors.centerIn: parent
            text: "󰮯"
            color: launcherMouse.containsMouse ? Colors.color(4) : Colors.foreground
            font.family: Appearance.iconFont
            font.pixelSize: 14
        }

        MouseArea {
            id: launcherMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Quickshell.execDetached(["qs", "ipc", "call", "launcher", "toggle"])
        }
    }

    Repeater {
        model: Hyprland.workspaces.values

        delegate: Rectangle {
            id: ws
            required property var modelData
            property bool active: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === modelData.id
            property bool occupied: modelData.windows > 0
            property bool hovered: wsMouse.containsMouse

            implicitWidth: active ? 28 : (occupied ? 18 : 10)
            implicitHeight: 18
            radius: 9
            color: active ? Colors.color(4) : (occupied ? Qt.rgba(1, 1, 1, 0.25) : Qt.rgba(1, 1, 1, 0.10))
            border.width: 1
            border.color: active ? Qt.rgba(1, 1, 1, 0.40) : (hovered ? Qt.rgba(1, 1, 1, 0.25) : Qt.rgba(1, 1, 1, 0.08))

            Text {
                visible: ws.active || ws.hovered
                anchors.centerIn: parent
                text: ws.modelData.id
                color: ws.active ? Colors.background : Colors.textMain
                font.family: Appearance.fontFamily
                font.pixelSize: 11
                font.bold: true
            }

            Behavior on implicitWidth {
                NumberAnimation {
                    duration: Appearance.animFast
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on color {
                ColorAnimation {
                    duration: Appearance.animFast
                }
            }

            MouseArea {
                id: wsMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + ws.modelData.id)
            }
        }
    }
}
