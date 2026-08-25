import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import qs.config

RowLayout {
    id: root
    spacing: 6

    Repeater {
        model: Hyprland.workspaces.values

        delegate: Rectangle {
            id: dot
            required property var modelData
            property bool active: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === modelData.id

            width: active ? 22 : 10
            height: 10
            radius: 5
            color: active ? Colors.color(4) : Qt.rgba(1, 1, 1, 0.25)

            Behavior on width {
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
                anchors.fill: parent
                anchors.margins: -4 // bigger hit target than the visible dot
                onClicked: Hyprland.dispatch("workspace " + dot.modelData.id)
            }
        }
    }
}
