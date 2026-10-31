import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
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

            // ---------------- Floating status capsule ----------------
            Item {
                id: pillRow
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: Appearance.barHeight

                GlassCard {
                    id: barCapsule
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    height: parent.height - 10
                    width: barContent.implicitWidth + 30
                    cardRadius: height / 2
                    surfaceOpacity: 0.86
                    borderColor: Qt.rgba(1, 1, 1, 0.20)
                    shadowRadius: Appearance.shadowRadiusMedium
                    shadowOffset: Appearance.shadowOffsetSmall
                    showHighlight: false
                    showTint: true

                    RowLayout {
                        id: barContent
                        anchors.fill: parent
                        anchors.leftMargin: 13
                        anchors.rightMargin: 13
                        spacing: 12

                        Workspaces {
                            id: workspacesContent
                        }

                        Rectangle {
                            Layout.preferredWidth: 1
                            Layout.preferredHeight: 20
                            color: Qt.rgba(1, 1, 1, 0.18)
                        }

                        RowLayout {
                            id: centerContent
                            spacing: 10

                            MediaPill { id: mediaWidget }

                            Rectangle {
                                visible: mediaWidget.visible
                                Layout.preferredWidth: 1
                                Layout.preferredHeight: 14
                                color: Qt.rgba(1, 1, 1, 0.18)
                            }

                            Clock { id: clockContent }
                        }

                        Rectangle {
                            Layout.preferredWidth: 1
                            Layout.preferredHeight: 20
                            color: Qt.rgba(1, 1, 1, 0.18)
                        }

                        RowLayout {
                            id: statusContent
                            spacing: 10

                            Volume { compact: true }
                            Backlight { compact: true }
                            Battery { compact: true }
                            Network { compact: true }

                            Rectangle {
                                Layout.preferredWidth: 1
                                Layout.preferredHeight: 14
                                color: Qt.rgba(1, 1, 1, 0.18)
                            }

                            NotificationBell {
                                panelOpen: win.panelOpen
                                onTogglePanel: PanelState.toggle(win.modelData.name)
                            }
                            Tray {}
                        }
                    }
                }

            }

            // ---------------- Control Center dropdown ----------------
            Item {
                id: dropdownHost
                anchors.top: pillRow.bottom
                anchors.topMargin: 8
                anchors.right: parent.right
                anchors.rightMargin: 12
                width: 440
                height: win.panelOpen ? bg.implicitHeight : 0
                clip: true

                Behavior on height {
                    NumberAnimation {
                        duration: 320
                        easing.type: Easing.OutExpo
                    }
                }

                GlassCard {
                    id: bg
                    width: parent.width
                    implicitHeight: Math.min(content.implicitHeight + 36, Math.max(320, win.screen.height - Appearance.barHeight - 28))
                    height: implicitHeight

                    cardRadius: Appearance.radiusLarge

                    surfaceOpacity: Appearance.panelOpacity
                    shadowRadius: Appearance.shadowRadiusLarge
                    shadowOffset: Appearance.shadowOffsetLarge
                    showHighlight: false

                    // Pop‑out scaling & fade
                    transform: Scale {
                        id: popScale
                        origin.x: bg.width
                        origin.y: 0
                        xScale: win.panelOpen ? 1 : 0.85
                        yScale: win.panelOpen ? 1 : 0.85
                    }
                    opacity: win.panelOpen ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on transform {
                        NumberAnimation {
                            duration: 280
                            easing.type: Easing.OutExpo
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                    }

                    // Content with staggered fade‑in
                    ScrollView {
                        id: panelScroll
                        anchors.fill: parent
                        anchors.margins: 18
                        clip: true
                        contentWidth: availableWidth

                        ControlCenterContent {
                            id: content
                            width: panelScroll.availableWidth
                            panelOpen: win.panelOpen
                            opacity: win.panelOpen ? 1 : 0

                            Behavior on opacity {
                                NumberAnimation { duration: 200 }
                            }
                        }
                    }
                }
            }
        }
    }
}
