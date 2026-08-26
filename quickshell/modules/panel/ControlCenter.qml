import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import qs.config
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
        visible: PanelState.controlCenterOpen
        color: "transparent"
        exclusiveZone: 0
        WlrLayershell.namespace: "quickshell:panel"

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        onVisibleChanged: if (visible)
            popAnim.start()

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
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 58
                width: 400
                height: Math.min(760, 340 + notifList.contentHeight)
                radius: 26
                color: Colors.background
                opacity: Appearance.panelOpacity
                border.width: 1
                border.color: Colors.color(1)

                transformOrigin: Item.Top
                scale: 0.85

                SequentialAnimation {
                    id: popAnim
                    NumberAnimation {
                        target: card
                        property: "scale"
                        to: 1
                        duration: 220
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.1
                    }
                }

                MouseArea {
                    anchors.fill: parent
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "  Control Center"
                            color: Colors.foreground
                            font.family: Appearance.fontFamily
                            font.pixelSize: 18
                            font.bold: true
                            Layout.fillWidth: true
                        }
                        Button {
                            text: " Clear All"
                            onClicked: Notifications.clearAll()
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "  Do Not Disturb"
                            color: Colors.foreground
                            font.family: Appearance.fontFamily
                            Layout.fillWidth: true
                        }
                        Switch {
                            checked: Notifications.dnd
                            onToggled: Notifications.toggleDnd()
                        }
                    }

                    ColumnLayout {
                        id: volumeSection
                        Layout.fillWidth: true
                        spacing: 4
                        readonly property PwNode sink: Pipewire.defaultAudioSink

                        PwObjectTracker {
                            objects: [volumeSection.sink]
                        }

                        Text {
                            text: "  Volume"
                            color: Colors.foreground
                            font.family: Appearance.fontFamily
                        }
                        Slider {
                            Layout.fillWidth: true
                            from: 0
                            to: 1
                            value: volumeSection.sink?.audio?.volume ?? 0
                            onMoved: {
                                if (volumeSection.sink?.audio)
                                    volumeSection.sink.audio.volume = value;
                            }
                        }
                    }

                    ColumnLayout {
                        id: blSection
                        Layout.fillWidth: true
                        spacing: 4
                        property real percent: 50

                        Text {
                            text: "  Brightness"
                            color: Colors.foreground
                            font.family: Appearance.fontFamily
                        }
                        Slider {
                            id: blSlider
                            Layout.fillWidth: true
                            from: 1
                            to: 100
                            value: blSection.percent
                            onMoved: {
                                blSection.percent = value;
                                setBrightness.running = true;
                            }
                        }

                        Process {
                            id: getBrightness
                            command: ["brightnessctl", "-m"]
                            running: true
                            stdout: StdioCollector {
                                onStreamFinished: {
                                    const match = this.text.match(/,(\d+)%,/);
                                    if (match)
                                        blSection.percent = Number(match[1]);
                                }
                            }
                        }

                        Process {
                            id: setBrightness
                            command: ["brightnessctl", "set", Math.round(blSlider.value) + "%"]
                        }
                    }

                    ColumnLayout {
                        id: mprisSection
                        Layout.fillWidth: true
                        visible: Mpris.players.values.length > 0
                        spacing: 6
                        property var player: Mpris.players.values[0] ?? null

                        Text {
                            text: mprisSection.player ? mprisSection.player.trackTitle : ""
                            color: Colors.foreground
                            font.bold: true
                            font.family: Appearance.fontFamily
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        Text {
                            text: mprisSection.player ? mprisSection.player.trackArtist : ""
                            color: Colors.color(7)
                            font.family: Appearance.fontFamily
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        RowLayout {
                            spacing: 10
                            Button {
                                text: "󰒮"
                                onClicked: mprisSection.player?.previous()
                            }
                            Button {
                                text: mprisSection.player?.playbackState === MprisPlaybackState.Playing ? "󰏤" : "󰐊"
                                onClicked: mprisSection.player?.togglePlaying()
                            }
                            Button {
                                text: "󰒭"
                                onClicked: mprisSection.player?.next()
                            }
                        }
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

                            ColumnLayout {
                                id: contentCol
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 2

                                RowLayout {
                                    Layout.fillWidth: true
                                    Text {
                                        text: modelData.appName
                                        color: Colors.color(7)
                                        font.pixelSize: 11
                                        Layout.fillWidth: true
                                    }
                                    Button {
                                        text: "✕"
                                        flat: true
                                        onClicked: Notifications.dismiss(modelData)
                                    }
                                }
                                Text {
                                    text: modelData.summary
                                    color: Colors.foreground
                                    font.bold: true
                                    wrapMode: Text.Wrap
                                    Layout.fillWidth: true
                                }
                                Text {
                                    visible: modelData.body.length > 0
                                    text: modelData.body
                                    color: Colors.foreground
                                    opacity: 0.85
                                    wrapMode: Text.Wrap
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: notifList.count === 0
                            text: "No notifications"
                            color: Colors.color(8)
                            font.family: Appearance.fontFamily
                        }
                    }
                }
            }
        }
    }
}
