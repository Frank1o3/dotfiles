import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
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

            // FIXED to the content's natural size — NOT to dropdownHost's
            // animated height. This only changes when real content changes
            // (new notification, MPRIS state), never mid-animation, so the
            // actual Wayland surface only resizes rarely instead of every frame.
            implicitHeight: Appearance.barHeight + bg.implicitHeight
            color: "transparent"

            // Click-through mask: only the pill + whatever's currently visible
            // of the dropdown is clickable. Everything else in the reserved
            // space passes clicks straight through to windows behind it.
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
