import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.config.components
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

            // ---------------- Three pills ----------------
            Item {
                id: pillRow
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: Appearance.barHeight

                // Left pill: Workspaces
                GlassCard {
                    id: leftPill
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    height: parent.height - 12
                    width: workspacesContent.implicitWidth + 24
                    cardRadius: Appearance.radius
                    surfaceOpacity: Appearance.glassOpacity
                    shadowRadius: Appearance.shadowRadiusMedium
                    shadowOffset: Appearance.shadowOffsetMedium

                    Workspaces {
                        id: workspacesContent
                        anchors.centerIn: parent
                    }
                }

                // Center pill: Clock
                GlassCard {
                    id: centerPill
                    anchors.centerIn: parent
                    height: parent.height - 12
                    // Keep it compact – width fits the clock text plus padding, but not too wide
                    width: Math.min(clockContent.implicitWidth + 24, 280)
                    cardRadius: Appearance.radius
                    surfaceOpacity: Appearance.glassOpacity
                    shadowRadius: Appearance.shadowRadiusMedium
                    shadowOffset: Appearance.shadowOffsetMedium

                    Clock {
                        id: clockContent
                        anchors.centerIn: parent
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                // Right pill: System status
                GlassCard {
                    id: rightPill
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    height: parent.height - 12
                    width: rightContent.implicitWidth + 24
                    cardRadius: Appearance.radius
                    surfaceOpacity: Appearance.glassOpacity
                    shadowRadius: Appearance.shadowRadiusMedium
                    shadowOffset: Appearance.shadowOffsetMedium

                    RowLayout {
                        id: rightContent
                        anchors.centerIn: parent
                        spacing: Appearance.spacing

                        Igpu {}
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

            // ---------------- Control Center dropdown ----------------
            Item {
                id: dropdownHost
                anchors.top: pillRow.bottom
                anchors.right: parent.right
                anchors.rightMargin: 10
                width: 420
                height: win.panelOpen ? bg.implicitHeight : 0
                clip: true

                Behavior on height {
                    NumberAnimation {
                        duration: 280
                        easing.type: Easing.OutExpo
                    }
                }

                GlassCard {
                    id: bg
                    width: parent.width
                    implicitHeight: content.implicitHeight + 36
                    height: implicitHeight

                    topLeftRadius: 0
                    topRightRadius: 0
                    bottomLeftRadius: Appearance.radiusLarge
                    bottomRightRadius: Appearance.radiusLarge

                    surfaceOpacity: Appearance.panelOpacity
                    shadowRadius: Appearance.shadowRadiusLarge
                    shadowOffset: Appearance.shadowOffsetLarge
                    showHighlight: false

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
