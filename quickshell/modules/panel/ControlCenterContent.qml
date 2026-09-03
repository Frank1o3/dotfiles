import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Bluetooth
import qs.config
import qs.config.components
import qs.services

ColumnLayout {
    id: root
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
        }
        GlassButton {
            icon: "󰆴"
            text: "Clear"
            onClicked: Notifications.clearAll()
        }
    }

    Rectangle {
        Layout.fillWidth: true
        visible: GameMode.active
        radius: 14
        color: Qt.rgba(0.96, 0.76, 0.86, 0.12)
        implicitHeight: gmRow.implicitHeight + 20

        RowLayout {
            id: gmRow
            anchors.fill: parent
            anchors.margins: 10
            Text {
                text: "󰊴  Game Mode active — stats paused, only critical alerts shown"
                color: Colors.foreground
                font.family: Appearance.fontFamily
                font.pixelSize: Appearance.fontSize
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }
        }
    }

    // --- Connectivity card ---
    Rectangle {
        Layout.fillWidth: true
        radius: 14
        color: Qt.rgba(1, 1, 1, 0.045)
        implicitHeight: connCol.implicitHeight + 24

        ColumnLayout {
            id: connCol
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            readonly property BluetoothAdapter btAdapter: Bluetooth.defaultAdapter
            property bool wifiOn: false

            Process {
                id: wifiStatus
                command: ["nmcli", "radio", "wifi"]
                running: true
                stdout: StdioCollector {
                    onStreamFinished: connCol.wifiOn = this.text.trim() === "enabled"
                }
            }
            Process {
                id: wifiSet
            }

            RowLayout {
                Text {
                    text: "󰤨  Wi-Fi"
                    color: Colors.foreground
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSize + 1
                    Layout.fillWidth: true
                }
                GlassSwitch {
                    checked: connCol.wifiOn
                    onToggled: {
                        connCol.wifiOn = !connCol.wifiOn;
                        wifiSet.command = ["nmcli", "radio", "wifi", connCol.wifiOn ? "on" : "off"];
                        wifiSet.running = true;
                    }
                }
            }

            RowLayout {
                Text {
                    text: "󰂯  Bluetooth"
                    color: Colors.foreground
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSize + 1
                    Layout.fillWidth: true
                }
                GlassSwitch {
                    checked: connCol.btAdapter?.enabled ?? false
                    onToggled: {
                        if (connCol.btAdapter)
                            connCol.btAdapter.enabled = !connCol.btAdapter.enabled;
                    }
                }
            }

            // Paired/connected devices — only shown once the adapter is on
            ColumnLayout {
                Layout.fillWidth: true
                visible: (connCol.btAdapter?.enabled ?? false) && connCol.btAdapter.devices.values.length > 0
                spacing: 4

                Repeater {
                    model: connCol.btAdapter ? connCol.btAdapter.devices.values : []

                    delegate: RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: 2
                        required property var modelData

                        Text {
                            text: modelData.connected ? "󰂱" : "󰂯"
                            color: modelData.connected ? Colors.color(4) : Colors.color(8)
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSize
                        }
                        Text {
                            text: modelData.name
                            color: Colors.foreground
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSize
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        GlassButton {
                            text: modelData.connected ? "Disconnect" : "Connect"
                            onClicked: modelData.connected ? modelData.disconnect() : modelData.connect()
                        }
                    }
                }
            }
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
                onMoved: v => {
                    setBrightness.command = ["brightnessctl", "set", Math.round(v) + "%"];
                    setBrightness.running = true;
                }

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
            }
            Text {
                text: mprisCol.player ? mprisCol.player.trackArtist : ""
                color: Colors.color(7)
                font.family: Appearance.fontFamily
                Layout.fillWidth: true
                elide: Text.ElideRight
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
    }

    // No fillHeight here — this Column sizes to its content since the
    // whole panel now grows/shrinks by height animation, so the list
    // gets a capped preferred height and scrolls internally past that.
    ListView {
        id: notifList
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(360, contentHeight)
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
                }
                Text {
                    visible: modelData.body.length > 0
                    text: modelData.body
                    color: Colors.foreground
                    opacity: 0.85
                    font.family: Appearance.fontFamily
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
