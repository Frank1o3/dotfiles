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
import qs.services

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
            visible: true
            WlrLayershell.namespace: "quickshell:bar"

            IdleInhibitor {
                window: win
                enabled: Caffeine.active
            }

            readonly property bool panelOpen: PanelState.isOpen(modelData.name)

            anchors {
                top: true
                left: true
                right: true
            }

            exclusiveZone: OverlayState.barHidden ? 0 : Appearance.barHeight

            implicitHeight: Appearance.barHeight + bg.implicitHeight
            color: "transparent"

            mask: Region {
                item: OverlayState.barHidden ? null : pillRow
                Region {
                    item: OverlayState.barHidden || !win.panelOpen ? null : dropdownHost
                }
            }

            HyprlandFocusGrab {
                windows: [win]
                active: win.panelOpen && !OverlayState.barHidden
                onCleared: PanelState.setOpen(win.modelData.name, false)
            }

            Connections {
                target: OverlayState
                function onBarHiddenChanged() {
                    if (OverlayState.barHidden && win.panelOpen)
                        PanelState.setOpen(win.modelData.name, false);
                }
            }

            // ---------------- Floating status capsule ----------------
            Item {
                id: pillRow
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: Appearance.barHeight
                property real reveal: OverlayState.barHidden ? 0 : 1
                opacity: reveal
                enabled: !OverlayState.barHidden

                transform: Translate { y: (1 - pillRow.reveal) * -12 }
                Behavior on reveal { NumberAnimation { duration: Appearance.animNormal; easing.type: Easing.OutCubic } }

                GlassCard {
                    id: barCapsule
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    height: parent.height - 10
                    width: barContent.implicitWidth + 30
                    cardRadius: height / 2
                    surfaceOpacity: Appearance.surfaceOpacity
                    borderColor: Colors.outline
                    shadowRadius: Appearance.shadowRadiusMedium
                    shadowOffset: Appearance.shadowOffsetSmall

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
                            color: Colors.divider
                        }

                        RowLayout {
                            id: centerContent
                            spacing: 10

                            MediaPill { id: mediaWidget }

                            Rectangle {
                                visible: mediaWidget.visible
                                Layout.preferredWidth: 1
                                Layout.preferredHeight: 14
                                color: Colors.divider
                            }

                            Clock { id: clockContent }
                        }

                        Rectangle {
                            Layout.preferredWidth: 1
                            Layout.preferredHeight: 20
                            color: Colors.divider
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
                                color: Colors.divider
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
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.min(960, parent.width - 24)
                height: win.panelOpen && !OverlayState.barHidden ? bg.implicitHeight : 0
                clip: true

                Behavior on height {
                    NumberAnimation {
                        duration: Appearance.animSlow
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

                    // Pop‑out scaling & fade
                    transform: Scale {
                        id: popScale
                        origin.x: bg.width / 2
                        origin.y: 0
                        xScale: win.panelOpen ? 1 : 0.85
                        yScale: win.panelOpen ? 1 : 0.85
                    }
                    opacity: win.panelOpen && !OverlayState.barHidden ? 1 : 0

                    Behavior on opacity {
                        NumberAnimation {
                            duration: Appearance.animFast
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on transform {
                        NumberAnimation {
                            duration: Appearance.animNormal
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
                                NumberAnimation { duration: Appearance.animFast }
                            }
                        }
                    }
                }
            }
        }
    }
}
