import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import qs.config
import qs.modules.bar.widgets
import qs.modules.panel

Scope {
    id: root

    readonly property string focusedScreen: Hyprland.focusedMonitor?.name ?? ""

    IpcHandler {
        target: "notifications"
        function toggle(): void {
            PanelState.toggle(root.focusedScreen);
        }
        function open(): void {
            PanelState.setOpen(root.focusedScreen, true);
        }
        function close(): void {
            PanelState.closeAll();
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property var modelData
            screen: modelData
            WlrLayershell.namespace: "quickshell:bar"

            readonly property bool panelOpen: PanelState.isOpen(modelData.name)

            anchors {
                top: true
                left: true
                right: true
            }

            exclusiveZone: Appearance.barHeight

            implicitHeight: Appearance.barHeight + bg.implicitHeight
            color: "transparent"

            mask: Region {
                item: pillRow
                Region {
                    item: dropdownHost
                }
            }

            HyprlandFocusGrab {
                windows: [win]
                active: win.panelOpen
                onCleared: PanelState.setOpen(win.modelData.name, false)
            }

            // ---------------- Bar pill ----------------
            Item {
                id: pillRow
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: Appearance.barHeight

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

                    layer.enabled: true
                    layer.effect: DropShadow {
                        transparentBorder: true
                        radius: 16
                        samples: 33
                        verticalOffset: 4
                        color: "#66000000"
                    }
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

                    Rectangle {
                        anchors.centerIn: parent
                        width: Math.min(110, parent.width * 0.28)
                        height: 24
                        radius: 12
                        color: Qt.rgba(1, 1, 1, Appearance.panelSurfaceOpacity)
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, Appearance.panelBorderOpacity)

                        Clock {
                            anchors.centerIn: parent
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                        }
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

                        Rectangle {
                            Layout.preferredWidth: 1
                            Layout.preferredHeight: 16
                            color: Colors.foreground
                            opacity: 0.15
                        }

                        Volume {}
                        Backlight {}
                        Battery {}

                        Rectangle {
                            Layout.preferredWidth: 1
                            Layout.preferredHeight: 16
                            color: Colors.foreground
                            opacity: 0.15
                        }

                        NotificationBell {
                            panelOpen: win.panelOpen
                            onTogglePanel: PanelState.toggle(win.modelData.name)
                        }
                        Tray {}
                    }
                }
            }

            // ---------------- Control Center, grown out of the pill ----------------
            Item {
                id: dropdownHost
                anchors.top: pillRow.bottom
                anchors.right: parent.right
                anchors.rightMargin: 10
                width: 380
                height: win.panelOpen ? bg.implicitHeight : 0
                clip: true

                Behavior on height {
                    NumberAnimation {
                        duration: 280
                        easing.type: Easing.OutExpo
                    }
                }

                Rectangle {
                    id: bg
                    width: parent.width
                    implicitHeight: content.implicitHeight + 36
                    height: implicitHeight

                    topLeftRadius: 0
                    topRightRadius: 0
                    bottomLeftRadius: Appearance.radius
                    bottomRightRadius: Appearance.radius

                    color: Colors.background
                    opacity: Appearance.panelOpacity
                    border.width: 1
                    border.color: Colors.color(1)

                    layer.enabled: true
                    layer.effect: DropShadow {
                        transparentBorder: true
                        radius: 20
                        samples: 41
                        verticalOffset: 6
                        color: "#77000000"
                    }

                    MouseArea {
                        anchors.fill: parent
                    }

                    ControlCenterContent {
                        id: content
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 18
                    }
                }
            }
        }
    }
}
