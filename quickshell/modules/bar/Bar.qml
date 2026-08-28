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

    // Convenience: the screen that Hyprland currently considers focused.
    readonly property string focusedScreen: Hyprland.focusedMonitor?.name ?? ""

    // Single global IPC handler — declared once here, not inside Variants,
    // so it isn't re-registered per monitor.
    // Targets the *focused* monitor's panel instance.
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

            // Per-instance open state, derived from the singleton map.
            readonly property bool panelOpen: PanelState.isOpen(modelData.name)

            anchors {
                top: true
                left: true
                right: true
            }

            // Reserve only the bar's own height for tiling purposes.
            // Setting exclusiveZone switches exclusionMode to Normal
            // automatically, so the dropdown below can grow without
            // pushing tiled windows down.
            exclusiveZone: Appearance.barHeight

            implicitHeight: Appearance.barHeight + dropdownHost.height
            color: "transparent"

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
                // Anchored just below the bar row.  We use pillRow
                // (a sibling) rather than pill (pillRow's child) because
                // QML anchoring only works between parent/sibling items.
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

                    // Flat where it meets the pill, rounded where it ends —
                    // this is what sells the "grew out of the bar" look.
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
                    } // eat clicks so they don't fall through to close

                    ControlCenterContent {
                        id: content
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 18
                    }
                }
            }

            // click on the desktop below the panel closes it
            MouseArea {
                anchors.top: dropdownHost.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                onClicked: PanelState.setOpen(win.modelData.name, false)
            }
        }
    }
}
