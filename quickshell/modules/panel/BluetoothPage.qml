import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import qs.config
import qs.config.components

ColumnLayout {
    id: root
    spacing: 12
    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property var devices: root.adapter?.devices?.values ?? []

    function getDeviceIcon(iconName, deviceName) {
        const name = (iconName || deviceName || "").toLowerCase();
        if (name.includes("head") || name.includes("audio") || name.includes("ear") || name.includes("sound")) return "󰋋";
        if (name.includes("keyboard")) return "󰌌";
        if (name.includes("mouse") || name.includes("trackball")) return "󰍽";
        if (name.includes("game") || name.includes("controller") || name.includes("pad")) return "󰊴";
        if (name.includes("phone")) return "󰏲";
        if (name.includes("watch")) return "󰂚";
        return "󰂯";
    }

    // Header & Adapter Toggle
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 64
        radius: Appearance.radiusLarge
        color: Qt.rgba(1, 1, 1, 0.035)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.08)

        RowLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            Rectangle {
                width: 36; height: 36; radius: 18
                color: root.adapter?.enabled ? Qt.rgba(Colors.color(6).r, Colors.color(6).g, Colors.color(6).b, 0.22) : Qt.rgba(1, 1, 1, 0.08)
                Text {
                    anchors.centerIn: parent
                    text: root.adapter?.enabled ? "󰂯" : "󰂲"
                    color: root.adapter?.enabled ? Colors.color(6) : Colors.color(7)
                    font.family: Appearance.iconFont
                    font.pixelSize: 18
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: root.adapter?.name ?? "Bluetooth"
                    color: Colors.foreground
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSize
                    font.bold: true
                }
                Text {
                    text: !root.adapter ? "No Bluetooth adapter found" : (root.adapter.enabled ? (root.adapter.discovering ? "Scanning for devices…" : "Ready & active") : "Turned off")
                    color: Colors.color(7)
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSizeSmall
                }
            }

            GlassSwitch {
                checked: root.adapter?.enabled ?? false
                onToggled: value => { if (root.adapter) root.adapter.enabled = value }
            }
        }
    }

    // Action Controls: Scan, Discoverable, Pairable
    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        visible: !!root.adapter && root.adapter.enabled

        GlassButton {
            Layout.fillWidth: true
            icon: root.adapter?.discovering ? "󰑐" : "󰐥"
            text: root.adapter?.discovering ? "Scanning…" : "Scan Devices"
            accent: root.adapter?.discovering ?? false
            onClicked: if (root.adapter) root.adapter.discovering = !root.adapter.discovering
        }

        GlassButton {
            Layout.fillWidth: true
            icon: (root.adapter?.discoverable ?? false) ? "󰘵" : "󰍹"
            text: (root.adapter?.discoverable ?? false) ? "Discoverable On" : "Make Discoverable"
            onClicked: if (root.adapter) {
                root.adapter.discoverableTimeout = 120;
                root.adapter.discoverable = !root.adapter.discoverable;
            }
        }

        GlassButton {
            Layout.fillWidth: true
            icon: (root.adapter?.pairable ?? false) ? "󰌹" : "󰌸"
            text: (root.adapter?.pairable ?? false) ? "Pairing On" : "Enable Pairing"
            onClicked: if (root.adapter) {
                root.adapter.pairableTimeout = 120;
                root.adapter.pairable = !root.adapter.pairable;
            }
        }
    }

    // Device List
    ListView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: !!root.adapter && root.adapter.enabled && root.devices.length > 0
        clip: true
        spacing: 8
        model: visible ? root.devices : []

        delegate: Rectangle {
            id: devCard
            required property var modelData
            width: ListView.view.width
            implicitHeight: 60
            radius: Appearance.radiusMedium
            color: modelData.connected
                ? Qt.rgba(Colors.color(6).r, Colors.color(6).g, Colors.color(6).b, 0.16)
                : Qt.rgba(1, 1, 1, 0.045)
            border.width: 1
            border.color: modelData.connected
                ? Qt.rgba(Colors.color(6).r, Colors.color(6).g, Colors.color(6).b, 0.40)
                : Qt.rgba(1, 1, 1, 0.07)

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 12
                spacing: 12

                // Device Type Icon
                Rectangle {
                    width: 34; height: 34; radius: 10
                    color: devCard.modelData.connected
                        ? Qt.rgba(Colors.color(6).r, Colors.color(6).g, Colors.color(6).b, 0.25)
                        : Qt.rgba(1, 1, 1, 0.06)

                    Text {
                        anchors.centerIn: parent
                        text: root.getDeviceIcon(devCard.modelData.icon, devCard.modelData.name)
                        color: devCard.modelData.connected ? Colors.color(6) : Colors.foreground
                        font.family: Appearance.iconFont
                        font.pixelSize: 16
                    }
                }

                // Name, Battery & Connection state
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: devCard.modelData.name || devCard.modelData.address || "Bluetooth Device"
                            color: Colors.foreground
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSize
                            font.bold: true
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        // Battery Indicator (if available)
                        Row {
                            visible: devCard.modelData.batteryAvailable
                            spacing: 3
                            Text {
                                text: "󰂀"
                                color: Colors.color(2)
                                font.family: Appearance.iconFont
                                font.pixelSize: 12
                            }
                            Text {
                                text: `${Math.round((devCard.modelData.battery ?? 0) * 100)}%`
                                color: Colors.color(7)
                                font.family: Appearance.fontFamily
                                font.pixelSize: 10
                                font.bold: true
                            }
                        }
                    }

                    Text {
                        text: devCard.modelData.connected
                            ? "Connected"
                            : (devCard.modelData.paired ? "Paired" : (devCard.modelData.pairing ? "Pairing…" : "Available"))
                        color: devCard.modelData.connected ? Colors.color(6) : Colors.color(7)
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSizeSmall
                    }
                }

                // Connect / Disconnect button
                GlassButton {
                    text: devCard.modelData.pairing
                        ? "Pairing…"
                        : (devCard.modelData.connected ? "Disconnect" : (devCard.modelData.paired ? "Connect" : "Pair"))
                    accent: devCard.modelData.connected
                    onClicked: {
                        if (devCard.modelData.pairing) return;
                        if (devCard.modelData.connected) devCard.modelData.disconnect();
                        else if (devCard.modelData.paired) devCard.modelData.connect();
                        else devCard.modelData.pair();
                    }
                }

                // Forget / Unpair button (only if paired or connected)
                Rectangle {
                    visible: devCard.modelData.paired
                    width: 28; height: 28; radius: 14
                    color: forgetMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "󰆴"
                        color: forgetMouse.containsMouse ? "#f38ba8" : Colors.color(7)
                        font.family: Appearance.iconFont
                        font.pixelSize: 13
                    }

                    MouseArea {
                        id: forgetMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: devCard.modelData.forget()
                    }
                }
            }
        }
    }

    // Empty / Off State
    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: !root.adapter || !root.adapter.enabled || root.devices.length === 0
        radius: Appearance.radiusLarge
        color: Qt.rgba(1, 1, 1, 0.035)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.07)

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 12

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 56; height: 56; radius: 28
                color: Qt.rgba(Colors.color(6).r, Colors.color(6).g, Colors.color(6).b, 0.14)
                Text {
                    anchors.centerIn: parent
                    text: !root.adapter ? "󰂲" : (!root.adapter.enabled ? "󰂲" : "󰂯")
                    color: Colors.color(6)
                    font.family: Appearance.iconFont
                    font.pixelSize: 26
                }
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 3
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: !root.adapter
                        ? "Bluetooth Unavailable"
                        : (!root.adapter.enabled ? "Bluetooth is Off" : "No Devices Found")
                    color: Colors.foreground
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSize + 1
                    font.bold: true
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: !root.adapter
                        ? "Check that BlueZ service is running."
                        : (!root.adapter.enabled ? "Turn Bluetooth on to connect devices." : "Click 'Scan Devices' to discover nearby devices.")
                    color: Colors.color(7)
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSizeSmall
                }
            }
        }
    }
}
