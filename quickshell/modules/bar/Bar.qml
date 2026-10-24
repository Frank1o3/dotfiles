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
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    height: parent.height - 12
                    width: workspacesContent.implicitWidth + 24
                    cardRadius: Math.round(height / 2)
                    surfaceOpacity: Appearance.glassOpacity
                    shadowRadius: Appearance.shadowRadiusSmall
                    shadowOffset: Appearance.shadowOffsetSmall

                    Workspaces {
                        id: workspacesContent
                        anchors.centerIn: parent
                    }
                }

                // Center pill: Media + Clock
                GlassCard {
                    id: centerPill
                    anchors.centerIn: parent
                    height: parent.height - 12
                    width: centerRow.implicitWidth + 28
                    cardRadius: Math.round(height / 2)
                    surfaceOpacity: Appearance.glassOpacity
                    shadowRadius: Appearance.shadowRadiusSmall
                    shadowOffset: Appearance.shadowOffsetSmall

                    RowLayout {
                        id: centerRow
                        anchors.centerIn: parent
                        spacing: 12

                        MediaPill {
                            id: mediaWidget
                        }

                        Rectangle {
                            visible: mediaWidget.visible
                            Layout.preferredWidth: 1
                            Layout.preferredHeight: 14
                            color: Qt.rgba(1, 1, 1, 0.20)
                        }

                        Clock {
                            id: clockContent
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }
                }

                // Right pill: System status
                GlassCard {
                    id: rightPill
                    anchors.right: parent.right
                    anchors.rightMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    height: parent.height - 12
                    width: rightContent.implicitWidth + 24
                    cardRadius: Math.round(height / 2)
                    surfaceOpacity: Appearance.glassOpacity
                    shadowRadius: Appearance.shadowRadiusSmall
                    shadowOffset: Appearance.shadowOffsetSmall

                    RowLayout {
                        id: rightContent
                        anchors.centerIn: parent
                        spacing: 10

                        Cpu {}
                        Memory {}

                        Rectangle {
                            Layout.preferredWidth: 1
                            Layout.preferredHeight: 14
                            color: Qt.rgba(1, 1, 1, 0.20)
                        }

                        Volume {}
                        Backlight {}
                        Battery {}
                        Network {}

                        Rectangle {
                            Layout.preferredWidth: 1
                            Layout.preferredHeight: 14
                            color: Qt.rgba(1, 1, 1, 0.20)
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
                    implicitHeight: content.implicitHeight + 36
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
                    ControlCenterContent {
                        id: content
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 18
                        opacity: win.panelOpen ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 200
                            }
                        }
                    }
                }
            }
        }
    }
}
