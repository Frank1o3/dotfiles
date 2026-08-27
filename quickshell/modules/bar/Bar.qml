import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.modules.bar.widgets

Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            WlrLayershell.namespace: "quickshell:bar"

            anchors {
                top: true
                left: true
                right: true
            }
            implicitHeight: Appearance.barHeight
            color: "transparent"

            Rectangle {
                id: pill
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                anchors.topMargin: 6
                anchors.bottomMargin: 6
                radius: Appearance.radius
                color: Colors.background
                opacity: Appearance.glassOpacity
                border.width: 1
                border.color: Colors.color(1)
            }

            Item {
                anchors.fill: pill
                anchors.leftMargin: 16
                anchors.rightMargin: 16

                RowLayout {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Appearance.spacing
                    Workspaces {}
                }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: Appearance.spacing
                    Clock {}
                }

                RowLayout {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Appearance.spacing
                    Cpu {}
                    Igpu {}
                    Temperature {}
                    Memory {}
                    Network {}
                    Volume {}
                    Backlight {}
                    Battery {}
                    NotificationBell {}
                    Tray {}
                }
            }
        }
    }
}
