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
            WlrLayershell.layer: UserSettings.layout("bar", { layer: "top" }).layer === "under" ? WlrLayer.Bottom : WlrLayer.Top
            property bool pointerInBar: false
            readonly property bool widgetMode: UserSettings.barMode.startsWith("widget")
            readonly property bool autoHide: UserSettings.barMode.endsWith("autohide")
            readonly property bool barShown: !OverlayState.barHidden && (!autoHide || pointerInBar || panelOpen)
            readonly property int barHeight: widgetMode ? Appearance.barHeight : 44
            readonly property real barScale: UserSettings.layout("bar", { scale: 1 }).scale

            Timer {
                id: autoHideTimer
                interval: 800
                repeat: false
                onTriggered: win.pointerInBar = false
            }

            IdleInhibitor {
                window: win
                enabled: Caffeine.active
            }

            readonly property bool panelOpen: PanelState.isOpen(modelData.name)
            onPanelOpenChanged: if (panelOpen) autoHideTimer.stop()

            // Keep the layer surface top/left/right anchored. A fourth
            // (bottom) anchor disables the exclusive-zone reservation, so
            // tiled windows would start underneath the physical bar.
            anchors { top: true; left: true; right: true }

            exclusiveZone: !win.widgetMode && win.barShown
                ? win.barHeight * win.barScale
                : 0

            implicitHeight: modelData.height
            color: "transparent"

            mask: Region {
                item: win.barShown ? barCapsule : null
                Region { item: win.barShown && win.panelOpen ? dropdownHost : null }
                Region { item: win.autoHide && !win.barShown ? revealZone : null }
            }

            Item {
                id: revealZone
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: 3
                visible: win.autoHide && !win.barShown && !OverlayState.barHidden
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: { win.pointerInBar = true; autoHideTimer.stop(); }
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

            // ---------------- Physical bar / floating widget ----------------
            Item {
                id: pillRow
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: win.barHeight
                property real reveal: win.barShown ? 1 : 0
                opacity: reveal
                enabled: !OverlayState.barHidden

                transform: Translate { y: (1 - pillRow.reveal) * -12 }
                Behavior on reveal { NumberAnimation { duration: Appearance.animNormal; easing.type: Easing.OutCubic } }

                GlassCard {
                    id: barCapsule
                    x: win.widgetMode ? UserSettings.position("bar", 0.5, 0.01).x * Math.max(0, win.width - width) : 0
                    y: win.widgetMode ? UserSettings.position("bar", 0.5, 0.01).y * Math.max(0, win.height - height) : 0
                    height: win.widgetMode ? parent.height - 10 : parent.height
                    width: win.widgetMode ? barContent.implicitWidth + 30 : win.width
                    transform: Scale {
                        origin.x: win.widgetMode ? 0 : barCapsule.width / 2
                        origin.y: 0
                        xScale: win.widgetMode ? win.barScale : 1
                        yScale: win.barScale
                    }
                    cardRadius: win.widgetMode ? height / 2 : 0
                    surfaceOpacity: win.widgetMode ? Appearance.surfaceOpacity : 1
                    borderColor: Colors.outline
                    borderWidth: win.widgetMode ? 1 : 0
                    shadowRadius: win.widgetMode ? Appearance.shadowRadiusMedium : 0
                    shadowOffset: win.widgetMode ? Appearance.shadowOffsetSmall : 0

                    HoverHandler {
                        enabled: win.autoHide
                        onHoveredChanged: {
                            if (hovered) { win.pointerInBar = true; autoHideTimer.stop(); }
                            else if (!win.panelOpen) autoHideTimer.restart();
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        z: 10
                        enabled: UserSettings.layoutEditMode
                        visible: UserSettings.layoutEditMode
                        cursorShape: UserSettings.layoutEditMode ? Qt.SizeAllCursor : Qt.ArrowCursor
                        drag.target: barCapsule
                        onReleased: UserSettings.savePosition("bar",
                            barCapsule.x / Math.max(1, win.width - barCapsule.width),
                            barCapsule.y / Math.max(1, win.height - barCapsule.height))
                    }

                    Rectangle {
                        z: 11
                        visible: UserSettings.layoutEditMode
                        width: 18; height: 18; radius: 5
                        anchors.right: parent.right; anchors.bottom: parent.bottom
                        color: Colors.accentColor
                        Text { anchors.centerIn: parent; text: "↘"; color: Colors.background; font.pixelSize: 12 }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.SizeFDiagCursor
                            property real initialScale: 1
                            property real initialX: 0
                            property real initialY: 0
                            onPressed: function(mouse) {
                                initialScale = UserSettings.layout("bar", { scale: 1 }).scale;
                                initialX = mouse.x; initialY = mouse.y;
                            }
                            onPositionChanged: function(mouse) {
                                if (pressed) UserSettings.setLayout("bar", {
                                    scale: Math.max(0.65, Math.min(1.8, initialScale + ((mouse.x - initialX) + (mouse.y - initialY)) / 180)),
                                    layer: UserSettings.layout("bar", { layer: "top" }).layer
                                });
                            }
                        }
                    }

                    RowLayout {
                        id: barContent
                        anchors.fill: parent
                        anchors.leftMargin: win.widgetMode ? 13 : 28
                        anchors.rightMargin: win.widgetMode ? 13 : 28
                        spacing: 12

                        Workspaces {
                            id: workspacesContent
                        }

                        Rectangle {
                            Layout.preferredWidth: 1
                            Layout.preferredHeight: 20
                            color: Colors.divider
                        }

                        Item { Layout.fillWidth: !win.widgetMode }

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

                        }

                        Item { Layout.fillWidth: !win.widgetMode }

                        Rectangle {
                            Layout.preferredWidth: 1
                            Layout.preferredHeight: 20
                            color: Colors.divider
                        }

                        RowLayout {
                            id: statusContent
                            spacing: 8

                            Volume { id: volumeWidget; compact: true }
                            Backlight { id: backlightWidget; compact: true }
                            Battery { id: batteryWidget; compact: true }
                            Network { id: networkWidget; compact: true }

                            Rectangle {
                                Layout.preferredWidth: 1
                                Layout.preferredHeight: 14
                                color: Colors.divider
                            }

                            NotificationBell {
                                id: notificationWidget
                                panelOpen: win.panelOpen
                                onTogglePanel: PanelState.toggle(win.modelData.name)
                            }
                            Tray { id: trayWidget }
                            Rectangle {
                                id: expandButton
                                Layout.preferredWidth: 30
                                Layout.preferredHeight: 28
                                radius: Appearance.radiusMedium
                                color: win.panelOpen
                                    ? Colors.accentSurface
                                    : expandClickArea.containsMouse ? Colors.surfaceHover : "transparent"
                                border.width: win.panelOpen ? 1 : 0
                                border.color: Colors.accentOutline

                                Text {
                                    anchors.centerIn: parent
                                    text: win.panelOpen ? "󰅁" : "󰅀"
                                    color: win.panelOpen ? Colors.color(4) : Colors.textMuted
                                    font.family: Appearance.iconFont
                                    font.pixelSize: 18
                                }

                                MouseArea {
                                    id: expandClickArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: PanelState.toggle(win.modelData.name, "home")
                                }
                            }
                        }
                    }

                    Rectangle {
                        visible: !win.widgetMode
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 1
                        color: Colors.outline
                    }
                }

            }

            // ---------------- Control Center dropdown ----------------
            Item {
                id: dropdownHost
                anchors.top: pillRow.bottom
                anchors.topMargin: win.widgetMode ? 8 : 0
                anchors.left: win.widgetMode ? undefined : parent.left
                anchors.horizontalCenter: win.widgetMode ? parent.horizontalCenter : undefined
                width: win.widgetMode ? Math.min(960, parent.width - 24) : parent.width
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
