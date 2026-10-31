import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs.config
import qs.config.components
import qs.services

ColumnLayout {
    id: root
    spacing: 12
    property bool panelOpen: false
    property bool brightnessAvailable: false
    // Each monitor has its own panel instance. Keep navigation local so a
    // different monitor opening or closing its panel cannot reset this page.
    property string page: ""
    readonly property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property string pageTitle: page === "wifi" ? "Wi-Fi"
        : page === "bluetooth" ? "Bluetooth"
        : page === "system" ? "System Monitor" : "Control Center"

    onPanelOpenChanged: if (!panelOpen) page = ""

    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: 38
        spacing: 8
        GlassButton {
            visible: root.page !== ""
            text: "‹"
            onClicked: root.page = ""
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1
            Text { text: root.pageTitle; color: Colors.foreground; font.family: Appearance.fontFamily; font.pixelSize: 19; font.bold: true }
            Text {
                visible: root.page === ""
                text: Qt.formatDateTime(new Date(), "dddd, MMM d · hh:mm AP")
                color: Colors.color(7)
                font.family: Appearance.fontFamily
                font.pixelSize: Appearance.fontSizeSmall
            }
        }
        Text {
            visible: root.page === ""
            text: GameMode.active ? "󰊴" : (Notifications.dnd ? "󰂛" : "●")
            color: Colors.color(4)
            font.family: Appearance.iconFont
            font.pixelSize: 17
        }
    }

    Loader {
        id: pageLoader
        Layout.fillWidth: true
        Layout.topMargin: 4
        sourceComponent: root.page === "wifi" ? wifiPage
            : root.page === "bluetooth" ? bluetoothPage
            : root.page === "system" ? systemPage : overview
        opacity: 1
        y: 0
        Behavior on opacity { NumberAnimation { duration: Appearance.animFast } }
        Behavior on y { NumberAnimation { duration: Appearance.animNormal; easing.type: Easing.OutCubic } }
        onSourceComponentChanged: pageTransition.restart()
    }

    SequentialAnimation {
        id: pageTransition
        PropertyAction { target: pageLoader; property: "opacity"; value: 0.45 }
        PropertyAction { target: pageLoader; property: "y"; value: 7 }
        ParallelAnimation {
            NumberAnimation { target: pageLoader; property: "opacity"; to: 1; duration: Appearance.animFast }
            NumberAnimation { target: pageLoader; property: "y"; to: 0; duration: Appearance.animNormal; easing.type: Easing.OutCubic }
        }
    }

    Component {
        id: overview
        ColumnLayout {
            spacing: 10
            Rectangle {
                Layout.fillWidth: true
                radius: Appearance.cardRadius
                color: Qt.rgba(1, 1, 1, 0.045)
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.06)
                implicitHeight: quickCol.implicitHeight + 24
                ColumnLayout {
                    id: quickCol
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8
                    SectionLabel { icon: "󰐥"; text: "Quick Settings" }
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: 7
                        rowSpacing: 7
                        QuickToggle {
                            Layout.fillWidth: true
                            icon: "󰤨"; label: "Wi-Fi"; active: Networking.wifiEnabled
                            subLabel: Networking.wifiEnabled ? (root.wifiDevice?.networks.values.find(n => n.connected)?.name ?? "Enabled") : "Disabled"
                            onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
                        }
                        QuickToggle {
                            Layout.fillWidth: true
                            icon: "󰂯"; label: "Bluetooth"; active: Bluetooth.defaultAdapter?.enabled ?? false
                            subLabel: Bluetooth.defaultAdapter ? (Bluetooth.defaultAdapter.enabled ? "Enabled" : "Disabled") : "Unavailable"
                            onClicked: if (Bluetooth.defaultAdapter) Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled
                        }
                        QuickToggle { Layout.fillWidth: true; icon: "󰂛"; label: "Do Not Disturb"; active: Notifications.dnd; subLabel: Notifications.dnd ? "On" : "Off"; onClicked: Notifications.toggleDnd() }
                        QuickToggle { Layout.fillWidth: true; icon: "󰊴"; label: "Game Mode"; active: GameMode.active; interactive: false; subLabel: GameMode.active ? "Active · effects off" : "Idle" }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                radius: Appearance.cardRadius
                color: Qt.rgba(1, 1, 1, 0.045)
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.06)
                implicitHeight: settingsCol.implicitHeight + 24
                ColumnLayout {
                    id: settingsCol
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 7
                    SectionLabel { icon: "󰍜"; text: "Settings" }
                    Repeater {
                        model: [
                            { icon: "󰤨", title: "Wi-Fi", detail: "Networks and connections", key: "wifi" },
                            { icon: "󰂯", title: "Bluetooth", detail: "Devices and pairing", key: "bluetooth" },
                            { icon: "󰍛", title: "System Monitor", detail: "CPU, memory, graphics and disks", key: "system" }
                        ]
                        delegate: Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: 52
                            radius: 11
                            color: settingsMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(1, 1, 1, 0.04)
                            border.width: 1
                            border.color: Qt.rgba(1, 1, 1, 0.05)
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 11
                                anchors.rightMargin: 11
                                spacing: 9
                                Text { text: modelData.icon; color: Colors.color(4); font.family: Appearance.iconFont; font.pixelSize: 18 }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1
                                    Text { text: modelData.title; color: Colors.foreground; font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSize; font.bold: true }
                                    Text { text: modelData.detail; color: Colors.color(7); font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSizeSmall }
                                }
                                Text { text: "󰅂"; color: Colors.color(7); font.family: Appearance.iconFont; font.pixelSize: 16 }
                            }
                            MouseArea {
                                id: settingsMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                activeFocusOnTab: true
                                Keys.onReturnPressed: root.page = modelData.key
                                Keys.onEnterPressed: root.page = modelData.key
                                Keys.onSpacePressed: root.page = modelData.key
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.page = modelData.key
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                radius: Appearance.cardRadius
                color: Qt.rgba(1, 1, 1, 0.045)
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.06)
                implicitHeight: controlsCol.implicitHeight + 24
                ColumnLayout {
                    id: controlsCol
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8
                    SectionLabel { icon: "󰕾"; text: "Quick Controls" }
                    readonly property PwNode sink: Pipewire.defaultAudioSink
                    PwObjectTracker { objects: [controlsCol.sink] }
                    Text {
                        visible: !controlsCol.sink?.audio
                        text: "No audio output device is available. Check that PipeWire is running."
                        color: Colors.color(7)
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSizeSmall
                        wrapMode: Text.Wrap
                        Layout.fillWidth: true
                    }
                    GlassSlider { visible: !!controlsCol.sink?.audio; Layout.fillWidth: true; icon: "󰕾"; value: controlsCol.sink?.audio?.volume ?? 0; onMoved: value => { if (controlsCol.sink?.audio) controlsCol.sink.audio.volume = value } }
                    Text {
                        visible: !root.brightnessAvailable
                        text: "No display brightness control is available."
                        color: Colors.color(7)
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSizeSmall
                        Layout.fillWidth: true
                    }
                    GlassSlider {
                        id: brightnessSlider
                        visible: root.brightnessAvailable
                        Layout.fillWidth: true
                        icon: "󰃟"
                        from: 1
                        to: 100
                        value: 50
                        onMoved: value => { brightnessSet.command = ["brightnessctl", "set", Math.round(value) + "%"]; brightnessSet.running = true }
                    }
                    Process {
                        id: brightnessGet
                        command: ["brightnessctl", "-m"]
                        running: true
                        stdout: StdioCollector {
                            onStreamFinished: {
                                const match = this.text.match(/^[^,\n]+,backlight,[^,\n]*,(\d+)%/m);
                                root.brightnessAvailable = !!match;
                                if (match) brightnessSlider.value = Number(match[1]);
                            }
                        }
                    }
                    Process { id: brightnessSet }
                }
            }
        }
    }

    Component { id: wifiPage; WifiPage {} }
    Component { id: bluetoothPage; BluetoothPage {} }
    Component { id: systemPage; SystemPage {} }
}
