import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import qs.config
import qs.config.components
import qs.services

Scope {
    id: root

    IpcHandler {
        target: "notifications"
        function toggle(): void {
            PanelState.toggleControlCenter();
        }
        function open(): void {
            PanelState.openControlCenter();
        }
        function close(): void {
            PanelState.closeControlCenter();
        }
    }

    PanelWindow {
        id: win
        visible: mapped
        color: "transparent"
        exclusiveZone: 0
        WlrLayershell.namespace: "quickshell:panel"

        property bool mapped: false
        Timer {
            id: closeTimer
            interval: 220
            onTriggered: win.mapped = false
        }
        property bool openLink: PanelState.controlCenterOpen
        onOpenLinkChanged: {
            if (openLink) {
                closeTimer.stop();
                win.mapped = true;
            } else
                closeTimer.start();
        }

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        HyprlandFocusGrab {
            windows: [win]
            active: PanelState.controlCenterOpen
            onCleared: PanelState.closeControlCenter()
        }

        MouseArea {
            anchors.fill: parent
            onClicked: PanelState.closeControlCenter()

            Rectangle {
                id: card
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: Appearance.barHeight + 4
                anchors.rightMargin: 10
                width: 380
                height: Math.min(760, 340 + notifList.contentHeight)
                radius: Appearance.radius
                color: Colors.background
                opacity: PanelState.controlCenterOpen ? Appearance.panelOpacity : 0
                border.width: 1
                border.color: Colors.color(1)

                transformOrigin: Item.TopRight
                scale: PanelState.controlCenterOpen ? 1 : 0.85

                Behavior on scale {
                    NumberAnimation {
                        duration: 240
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.08
                    }
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }

                Rectangle {
                    width: 20
                    height: 20
                    radius: 4
                    color: parent.color
                    opacity: parent.opacity
                    border.width: 1
                    border.color: parent.border.color
                    rotation: 45
                    anchors.horizontalCenter: parent.right
                    anchors.horizontalCenterOffset: -46
                    y: -9
                    z: -1
                }

                MouseArea {
                    anchors.fill: parent
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 14

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Control Center"
                            color: Colors.foreground
                            font.family: Appearance.fontFamily
                            font.pixelSize: 17
                            font.bold: true
                            Layout.fillWidth: true
                            font.weight: Font.Bold
                        }
                        GlassButton {
                            icon: "󰆴"
                            text: "Clear"
                            onClicked: Notifications.clearAll()
                        }
                    }

                    // --- DND card ---
                    Rectangle {
                        Layout.fillWidth: true
                        radius: 14
                        color: Qt.rgba(1, 1, 1, 0.045)
                        implicitHeight: dndRow.implicitHeight + 24

                        RowLayout {
                            id: dndRow
                            anchors.fill: parent
                            anchors.margins: 12
                            Text {
                                text: "󰂛  Do Not Disturb"
                                color: Colors.foreground
                                font.family: Appearance.fontFamily
                                font.pixelSize: Appearance.fontSize + 1
                                Layout.fillWidth: true
                                font.weight: Font.Bold
                            }
                            GlassSwitch {
                                checked: Notifications.dnd
                                onToggled: Notifications.toggleDnd()
                            }
                        }
                    }

                    // --- Volume / Brightness card ---
                    Rectangle {
                        Layout.fillWidth: true
                        radius: 14
                        color: Qt.rgba(1, 1, 1, 0.045)
                        implicitHeight: slidersCol.implicitHeight + 24

                        ColumnLayout {
                            id: slidersCol
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 14

                            readonly property PwNode sink: Pipewire.defaultAudioSink
                            PwObjectTracker {
                                objects: [slidersCol.sink]
                            }

                            GlassSlider {
                                Layout.fillWidth: true
                                icon: "󰕾"
                                from: 0
                                to: 1
                                value: slidersCol.sink?.audio?.volume ?? 0
                                onMoved: v => {
                                    if (slidersCol.sink?.audio)
                                        slidersCol.sink.audio.volume = v;
                                }
                            }

                            GlassSlider {
                                id: blSlider
                                Layout.fillWidth: true
                                icon: "󰃟"
                                from: 1
                                to: 100
                                value: 50
                                onMoved: v => setBrightness.command = ["brightnessctl", "set", Math.round(v) + "%"] && (setBrightness.running = true)

                                Process {
                                    id: getBrightness
                                    command: ["brightnessctl", "-m"]
                                    running: true
                                    stdout: StdioCollector {
                                        onStreamFinished: {
                                            const match = this.text.match(/,(\d+)%,/);
                                            if (match)
                                                blSlider.value = Number(match[1]);
                                        }
                                    }
                                }
                                Process {
                                    id: setBrightness
                                }
                            }
                        }
                    }

                    // --- Media card ---
                    Rectangle {
                        Layout.fillWidth: true
                        visible: Mpris.players.values.length > 0
                        radius: 14
                        color: Qt.rgba(1, 1, 1, 0.045)
                        implicitHeight: mprisCol.implicitHeight + 24

                        ColumnLayout {
                            id: mprisCol
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 6
                            property var player: Mpris.players.values[0] ?? null

                            Text {
                                text: mprisCol.player ? mprisCol.player.trackTitle : ""
                                color: Colors.foreground
                                font.bold: true
                                font.family: Appearance.fontFamily
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                font.weight: Font.Bold
                            }
                            Text {
                                text: mprisCol.player ? mprisCol.player.trackArtist : ""
                                color: Colors.color(7)
                                font.family: Appearance.fontFamily
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                font.weight: Font.Bold
                            }
                            RowLayout {
                                spacing: 8
                                Layout.topMargin: 4
                                GlassButton {
                                    icon: "󰒮"
                                    onClicked: mprisCol.player?.previous()
                                }
                                GlassButton {
                                    icon: mprisCol.player?.playbackState === MprisPlaybackState.Playing ? "󰏤" : "󰐊"
                                    accent: true
                                    onClicked: mprisCol.player?.togglePlaying()
                                }
                                GlassButton {
                                    icon: "󰒭"
                                    onClicked: mprisCol.player?.next()
                                }
                            }
                        }
                    }

                    Text {
                        text: "Notifications"
                        visible: notifList.count > 0
                        color: Colors.color(7)
                        font.family: Appearance.fontFamily
                        font.pixelSize: 12
                        font.bold: true
                        font.weight: Font.Bold
                    }

                    ListView {
                        id: notifList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 8
                        model: Notifications.list

                        delegate: Rectangle {
                            required property var modelData
                            width: notifList.width
                            height: contentCol.implicitHeight + 20
                            radius: 14
                            color: Qt.rgba(1, 1, 1, 0.05)
                            border.width: 1
                            border.color: Qt.rgba(1, 1, 1, 0.06)

                            Rectangle {
                                width: 3
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                radius: 2
                                color: Colors.color(4)
                            }

                            ColumnLayout {
                                id: contentCol
                                anchors.fill: parent
                                anchors.margins: 12
                                anchors.leftMargin: 16
                                spacing: 2

                                RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        text: modelData.appName
                                        color: Colors.color(7)
                                        font.pixelSize: 11
                                        font.family: Appearance.fontFamily
                                        Layout.fillWidth: true
                                        font.weight: Font.Bold
                                    }
                                    GlassButton {
                                        icon: "✕"
                                        onClicked: Notifications.dismiss(modelData)
                                    }
                                }
                                Text {
                                    text: modelData.summary
                                    color: Colors.foreground
                                    font.bold: true
                                    font.family: Appearance.fontFamily
                                    wrapMode: Text.Wrap
                                    Layout.fillWidth: true
                                    font.weight: Font.Bold
                                }
                                Text {
                                    visible: modelData.body.length > 0
                                    text: modelData.body
                                    color: Colors.foreground
                                    opacity: 0.85
                                    font.family: Appearance.fontFamily
                                    wrapMode: Text.Wrap
                                    Layout.fillWidth: true
                                    font.weight: Font.Bold
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: notifList.count === 0
                            text: "No notifications"
                            color: Colors.color(8)
                            font.family: Appearance.fontFamily
                            font.weight: Font.Bold
                        }
                    }
                }
            }
        }
    }
}
