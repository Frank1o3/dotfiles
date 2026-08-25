import Quickshell
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

            anchors {
                top: true
                left: true
                right: true
            }
            implicitHeight: Appearance.barHeight
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10

                // ── left ──
                BarPill {
                    Layout.alignment: Qt.AlignVCenter
                    content: [
                        Workspaces {}
                    ]
                }

                Item {
                    Layout.fillWidth: true
                }

                // ── center ──
                BarPill {
                    Layout.alignment: Qt.AlignVCenter
                    content: [
                        Clock {}
                    ]
                }

                Item {
                    Layout.fillWidth: true
                }

                // ── right ──
                BarPill {
                    Layout.alignment: Qt.AlignVCenter
                    content: [
                        Cpu {},
                        Igpu {},
                        Temperature {},
                        Memory {},
                        Network {},
                        Volume {},
                        Backlight {},
                        Battery {},
                        Tray {}
                    ]
                }
            }
        }
    }
}
