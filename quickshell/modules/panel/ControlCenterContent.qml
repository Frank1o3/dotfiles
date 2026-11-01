import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs.config
import qs.config.components
import qs.modules.panel
import qs.services

RowLayout {
    id: root

    spacing: 16
    implicitWidth: 860
    implicitHeight: 520

    property bool panelOpen: false
    property bool brightnessAvailable: false
    property string page: "home"
    readonly property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property string pageTitle: page === "wifi" ? "Wi-Fi"
        : page === "bluetooth" ? "Bluetooth"
        : page === "system" ? "System Monitor"
        : page === "settings" ? "Settings" : "Overview"
    readonly property var destinations: [
        { key: "home", title: "Home", icon: "󰋜" },
        { key: "wifi", title: "Wi-Fi", icon: "󰖩" },
        { key: "bluetooth", title: "Bluetooth", icon: "󰂯" },
        { key: "system", title: "System", icon: "󰍛" },
        { key: "settings", title: "Settings", icon: "󰒓" }
    ]

    onPanelOpenChanged: if (!panelOpen) page = "home"

    // Persistent navigation keeps destinations visible while the page changes.
    Rectangle {
        id: rail
        Layout.preferredWidth: 104
        Layout.fillHeight: true
        radius: Appearance.radiusLarge
        color: Qt.rgba(0, 0, 0, 0.24)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.07)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 9
            spacing: 6

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 42
                Layout.preferredHeight: 42
                radius: 15
                color: Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.18)
                Text {
                    anchors.centerIn: parent
                    text: "󰀻"
                    color: Colors.color(4)
                    font.family: Appearance.iconFont
                    font.pixelSize: 21
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                Layout.topMargin: 5
                Layout.bottomMargin: 3
                color: Qt.rgba(1, 1, 1, 0.10)
            }

            Repeater {
                model: root.destinations
                delegate: Item {
                    id: navItem
                    required property var modelData
                    readonly property bool selected: root.page === modelData.key
                    Layout.fillWidth: true
                    Layout.preferredHeight: 62

                    Rectangle {
                        anchors.fill: parent
                        radius: 15
                        color: navItem.selected
                            ? Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.22)
                            : navMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.07) : "transparent"
                        border.width: navItem.selected ? 1 : 0
                        border.color: Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.42)
                        Behavior on color { ColorAnimation { duration: Appearance.animFast } }

                        Column {
                            anchors.centerIn: parent
                            spacing: 4
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: navItem.modelData.icon
                                color: navItem.selected ? Colors.color(4) : Colors.textMuted
                                font.family: Appearance.iconFont
                                font.pixelSize: 19
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: navItem.modelData.title
                                color: navItem.selected ? Colors.foreground : Colors.textMuted
                                font.family: Appearance.fontFamily
                                font.pixelSize: 10
                                font.weight: navItem.selected ? Font.DemiBold : Font.Medium
                            }
                        }

                        MouseArea {
                            id: navMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.page = navItem.modelData.key
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "FLUID"
                color: Colors.textDim
                font.family: Appearance.fontFamily
                font.pixelSize: 9
                font.weight: Font.Bold
                font.letterSpacing: 1.2
            }
        }
    }

    Item {
        id: mainContent
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: 520
        implicitHeight: 520

        Item {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 66

            Column {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                Text {
                    text: root.page === "home" ? "Control Center" : "Settings"
                    color: Colors.foreground
                    font.family: Appearance.fontFamily
                    font.pixelSize: 21
                    font.weight: Font.Bold
                }
                Text {
                    text: root.page === "home"
                        ? Qt.formatDateTime(new Date(), "dddd, MMM d · hh:mm AP")
                        : root.pageTitle
                    color: Colors.color(7)
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSizeSmall
                }
            }

            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 92
                height: 32
                radius: 16
                color: Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.12)
                Row {
                    anchors.centerIn: parent
                    spacing: 6
                    Rectangle { anchors.verticalCenter: parent.verticalCenter; width: 6; height: 6; radius: 3; color: GameMode.active ? Colors.color(1) : Colors.color(4) }
                    Text {
                        text: GameMode.active ? "PERFORMANCE" : "READY"
                        color: Colors.foreground
                        font.family: Appearance.fontFamily
                        font.pixelSize: 9
                        font.weight: Font.Bold
                        font.letterSpacing: 0.6
                    }
                }
            }
        }

        Loader {
            id: pageLoader
            anchors.top: header.bottom
            anchors.topMargin: 12
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            sourceComponent: root.page === "wifi" ? wifiPage
                : root.page === "bluetooth" ? bluetoothPage
                : root.page === "system" ? systemPage
                : root.page === "settings" ? settingsPage : overview
            opacity: 1
            y: 0
            onSourceComponentChanged: pageTransition.restart()
        }

        SequentialAnimation {
            id: pageTransition
            PropertyAction { target: pageLoader; property: "opacity"; value: 0.55 }
            PropertyAction { target: pageLoader; property: "y"; value: 6 }
            ParallelAnimation {
                NumberAnimation { target: pageLoader; property: "opacity"; to: 1; duration: Appearance.animFast }
                NumberAnimation { target: pageLoader; property: "y"; to: 0; duration: Appearance.animNormal; easing.type: Easing.OutCubic }
            }
        }
    }

    Component {
        id: overview
        RowLayout {
            spacing: 14

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: quickContent.implicitHeight + 26
                    radius: Appearance.radiusLarge
                    color: Qt.rgba(1, 1, 1, 0.035)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.07)

                    ColumnLayout {
                        id: quickContent
                        anchors.fill: parent
                        anchors.margins: 13
                        spacing: 10
                        SectionLabel { icon: "󰐥"; text: "Quick Settings" }
                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            columnSpacing: 8
                            rowSpacing: 8
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
                            QuickToggle {
                                Layout.fillWidth: true
                                icon: "󰂛"; label: "Do Not Disturb"; active: Notifications.dnd
                                subLabel: Notifications.dnd ? "On" : "Off"
                                onClicked: Notifications.toggleDnd()
                            }
                            QuickToggle {
                                Layout.fillWidth: true
                                icon: "󰊴"; label: "Game Mode"; active: GameMode.active; interactive: false
                                subLabel: GameMode.active ? "Active" : "Idle"
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 142
                    radius: Appearance.radiusLarge
                    color: Qt.rgba(1, 1, 1, 0.035)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.07)

                    ColumnLayout {
                        id: controlContent
                        anchors.fill: parent
                        anchors.margins: 13
                        spacing: 11

                        SectionLabel { icon: "󰕾"; text: "Quick Controls" }
                        readonly property PwNode sink: Pipewire.defaultAudioSink
                        PwObjectTracker { objects: [controlContent.sink] }

                        Text {
                            visible: !controlContent.sink?.audio
                            text: "No audio output device is available. Check that PipeWire is running."
                            color: Colors.color(7)
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSizeSmall
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }
                        GlassSlider {
                            visible: !!controlContent.sink?.audio
                            Layout.fillWidth: true
                            icon: "󰕾"
                            value: controlContent.sink?.audio?.volume ?? 0
                            onMoved: value => { if (controlContent.sink?.audio) controlContent.sink.audio.volume = value }
                        }
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

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 146
                    radius: Appearance.radiusLarge
                    color: Qt.rgba(1, 1, 1, 0.035)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.07)
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 8
                        Text { text: "YOUR DEVICES"; color: Colors.color(7); font.family: Appearance.fontFamily; font.pixelSize: 10; font.bold: true; font.letterSpacing: 1 }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            Rectangle {
                                Layout.preferredWidth: 36; Layout.preferredHeight: 36; radius: 13
                                color: Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.15)
                                Text { anchors.centerIn: parent; text: Networking.wifiEnabled ? "󰤨" : "󰤭"; color: Colors.color(4); font.family: Appearance.iconFont; font.pixelSize: 18 }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Text { text: "Network"; color: Colors.foreground; font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSize; font.bold: true }
                                Text { text: Networking.wifiEnabled ? (root.wifiDevice?.networks.values.find(n => n.connected)?.name ?? "Wi-Fi enabled") : "Wi-Fi disabled"; color: Colors.color(7); font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSizeSmall; elide: Text.ElideRight; Layout.fillWidth: true }
                            }
                            Text { text: "›"; color: Colors.color(7); font.pixelSize: 21 }
                            TapHandler { onTapped: root.page = "wifi" }
                        }
                        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Qt.rgba(1, 1, 1, 0.08) }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            Rectangle {
                                Layout.preferredWidth: 36; Layout.preferredHeight: 36; radius: 13
                                color: Qt.rgba(Colors.color(6).r, Colors.color(6).g, Colors.color(6).b, 0.13)
                                Text { anchors.centerIn: parent; text: "󰂯"; color: Colors.color(6); font.family: Appearance.iconFont; font.pixelSize: 18 }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Text { text: "Bluetooth"; color: Colors.foreground; font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSize; font.bold: true }
                                Text { text: Bluetooth.defaultAdapter ? (Bluetooth.defaultAdapter.enabled ? `${Bluetooth.defaultAdapter.devices.values.filter(d => d.connected).length} connected` : "Turned off") : "Adapter unavailable"; color: Colors.color(7); font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSizeSmall }
                            }
                            Text { text: "›"; color: Colors.color(7); font.pixelSize: 21 }
                            TapHandler { onTapped: root.page = "bluetooth" }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 174
                    radius: Appearance.radiusLarge
                    color: Qt.rgba(1, 1, 1, 0.035)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.07)
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 11
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "System overview"; color: Colors.foreground; font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSize + 1; font.bold: true; Layout.fillWidth: true }
                            Text { text: "Open ›"; color: Colors.color(4); font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSizeSmall }
                        }
                        GaugeCard { Layout.fillWidth: true; Layout.fillHeight: true; icon: "󰍛"; label: "CPU usage"; value: SysMonitor.cpuUsage; unit: "%"; accent: Colors.color(1) }
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Do Not Disturb"; color: Colors.textMuted; font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSizeSmall; Layout.fillWidth: true }
                            Text { text: Notifications.dnd ? "On" : "Off"; color: Notifications.dnd ? Colors.color(4) : Colors.color(7); font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSizeSmall; font.bold: true }
                        }
                    }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.page = "system" }
                }
            }
        }
    }

    Component { id: wifiPage; WifiPage {} }
    Component { id: bluetoothPage; BluetoothPage {} }
    Component { id: systemPage; SystemPage {} }
    Component { id: settingsPage; SettingsPage { onNavigate: page => root.page = page } }
}
