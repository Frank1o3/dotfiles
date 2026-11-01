import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Networking
import qs.config
import qs.config.components

ColumnLayout {
    id: root
    spacing: 12

    readonly property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var wiredDevice: Networking.devices.values.find(d => d.type === DeviceType.Wired) ?? null
    property var selectedNetwork: null
    property string errorMessage: ""

    Component.onCompleted: if (wifiDevice && Networking.wifiEnabled) wifiDevice.scannerEnabled = true

    // Top Header: Wi-Fi Power Toggle & Quick Stats
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
                color: Networking.wifiEnabled ? Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.22) : Qt.rgba(1, 1, 1, 0.08)
                Text {
                    anchors.centerIn: parent
                    text: Networking.wifiEnabled ? "󰤨" : "󰤭"
                    color: Networking.wifiEnabled ? Colors.color(4) : Colors.color(7)
                    font.family: Appearance.iconFont
                    font.pixelSize: 18
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: "Wireless Network"
                    color: Colors.foreground
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSize
                    font.bold: true
                }
                Text {
                    text: !root.wifiDevice
                        ? "No Wi-Fi interface detected"
                        : (Networking.wifiEnabled ? (root.wifiDevice?.scannerEnabled ? "Scanning networks…" : "Wi-Fi enabled") : "Wi-Fi turned off")
                    color: Colors.color(7)
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSizeSmall
                }
            }

            GlassSwitch {
                checked: Networking.wifiEnabled
                onToggled: value => Networking.wifiEnabled = value
            }
        }
    }

    // Wired / Ethernet Card (if present)
    Rectangle {
        Layout.fillWidth: true
        visible: root.wiredDevice !== null
        implicitHeight: 56
        radius: Appearance.radiusLarge
        color: Qt.rgba(1, 1, 1, 0.035)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.08)

        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            Rectangle {
                width: 32; height: 32; radius: 16
                color: root.wiredDevice?.hasLink ? Qt.rgba(Colors.color(2).r, Colors.color(2).g, Colors.color(2).b, 0.22) : Qt.rgba(1, 1, 1, 0.06)
                Text {
                    anchors.centerIn: parent
                    text: "󰈀"
                    color: root.wiredDevice?.hasLink ? Colors.color(2) : Colors.color(7)
                    font.family: Appearance.iconFont
                    font.pixelSize: 16
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1
                Text {
                    text: "Wired Connection (Ethernet)"
                    color: Colors.foreground
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSize
                    font.bold: true
                }
                Text {
                    text: root.wiredDevice?.hasLink
                        ? `Connected · ${root.wiredDevice.linkSpeed ? root.wiredDevice.linkSpeed + ' Mbps' : 'Active link'}`
                        : "Cable unplugged"
                    color: Colors.color(7)
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSizeSmall
                }
            }

            GlassButton {
                text: "Network Editor"
                icon: "󰒓"
                onClicked: Quickshell.execDetached(["nm-connection-editor"])
            }
        }
    }

    // Wi-Fi Action & Scan Bar
    RowLayout {
        Layout.fillWidth: true
        visible: root.wifiDevice && Networking.wifiEnabled
        spacing: 8

        GlassButton {
            Layout.fillWidth: true
            icon: root.wifiDevice?.scannerEnabled ? "󰑐" : "󰤨"
            text: root.wifiDevice?.scannerEnabled ? "Scanning…" : "Scan for Networks"
            accent: root.wifiDevice?.scannerEnabled ?? false
            onClicked: if (root.wifiDevice) root.wifiDevice.scannerEnabled = true
        }

        GlassButton {
            icon: "󰒓"
            text: "Advanced Setup"
            onClicked: Quickshell.execDetached(["nm-connection-editor"])
        }
    }

    // Wi-Fi Network List
    ListView {
        id: wifiList
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: root.wifiDevice && Networking.wifiEnabled && (root.wifiDevice.networks?.values?.length ?? 0) > 0
        clip: true
        spacing: 8
        model: visible ? root.wifiDevice.networks.values : []

        delegate: Rectangle {
            id: netCard
            required property var modelData
            width: wifiList.width
            implicitHeight: 56
            radius: Appearance.radiusMedium
            color: modelData.connected
                ? Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.16)
                : Qt.rgba(1, 1, 1, 0.045)
            border.width: 1
            border.color: modelData.connected
                ? Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.45)
                : Qt.rgba(1, 1, 1, 0.07)

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 12
                spacing: 12

                Text {
                    text: modelData.connected ? "󰤨" : (modelData.signalStrength > 0.6 ? "󰤥" : (modelData.signalStrength > 0.3 ? "󰤢" : "󰤟"))
                    color: modelData.connected ? Colors.color(4) : Colors.color(7)
                    font.family: Appearance.iconFont
                    font.pixelSize: 18
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        text: modelData.name || "Hidden Network"
                        color: Colors.foreground
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSize
                        font.bold: true
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Row {
                        spacing: 6
                        Text {
                            text: modelData.connected ? "Connected" : (modelData.known ? "Saved" : `${Math.round((modelData.signalStrength ?? 0) * 100)}% signal`)
                            color: modelData.connected ? Colors.color(4) : Colors.color(7)
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSizeSmall
                        }
                        Text {
                            text: "•"
                            color: Colors.color(7)
                            font.pixelSize: 10
                            visible: modelData.security !== WifiSecurityType.Open
                        }
                        Text {
                            text: WifiSecurityType.toString(modelData.security)
                            color: Colors.color(7)
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSizeSmall
                            visible: modelData.security !== WifiSecurityType.Open
                        }
                    }
                }

                GlassButton {
                    text: modelData.connected ? "Connected" : "Connect"
                    accent: modelData.connected
                    onClicked: {
                        if (modelData.connected) return;
                        root.errorMessage = "";
                        if (modelData.known || modelData.security === WifiSecurityType.Open || modelData.security === WifiSecurityType.Owe)
                            modelData.connect();
                        else
                            root.selectedNetwork = modelData;
                    }
                }
            }

            Connections {
                target: modelData
                function onConnectionFailed(reason) {
                    root.errorMessage = ConnectionFailReason.toString(reason);
                }
            }
        }
    }

    // Password input popup card
    Rectangle {
        Layout.fillWidth: true
        visible: root.selectedNetwork !== null
        implicitHeight: visible ? 96 : 0
        radius: Appearance.radiusLarge
        color: Qt.rgba(0.08, 0.09, 0.14, 0.95)
        border.width: 1
        border.color: Colors.color(4)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            Text {
                text: `Connect to ${root.selectedNetwork?.name ?? "Network"}`
                color: Colors.foreground
                font.family: Appearance.fontFamily
                font.pixelSize: Appearance.fontSize
                font.bold: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                TextField {
                    id: psk
                    Layout.fillWidth: true
                    placeholderText: "Enter Wi-Fi password"
                    echoMode: TextInput.Password
                    color: Colors.foreground
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSizeSmall
                    background: Rectangle {
                        radius: 10
                        color: Qt.rgba(1, 1, 1, 0.08)
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.15)
                    }
                    onAccepted: connectBtn.clicked()
                }

                GlassButton {
                    id: connectBtn
                    text: "Connect"
                    accent: true
                    onClicked: {
                        root.errorMessage = "";
                        if (root.selectedNetwork) {
                            root.selectedNetwork.connectWithPsk(psk.text);
                            psk.text = "";
                            root.selectedNetwork = null;
                        }
                    }
                }

                GlassButton {
                    text: "Cancel"
                    onClicked: {
                        psk.text = "";
                        root.selectedNetwork = null;
                    }
                }
            }
        }
    }

    // Error message display
    Text {
        Layout.fillWidth: true
        visible: root.errorMessage.length > 0
        text: `Connection error: ${root.errorMessage}`
        color: "#f38ba8"
        font.family: Appearance.fontFamily
        font.pixelSize: Appearance.fontSizeSmall
        wrapMode: Text.Wrap
    }

    // Empty state
    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: !root.wifiDevice || !Networking.wifiEnabled || (root.wifiDevice.networks?.values?.length ?? 0) === 0
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
                color: Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.14)
                Text {
                    anchors.centerIn: parent
                    text: !Networking.wifiEnabled ? "󰤭" : "󰤨"
                    color: Colors.color(4)
                    font.family: Appearance.iconFont
                    font.pixelSize: 26
                }
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 3
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: !Networking.wifiEnabled ? "Wi-Fi is Turned Off" : (!root.wifiDevice ? "No Wi-Fi Adapter" : "No Networks Found")
                    color: Colors.foreground
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSize + 1
                    font.bold: true
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: !Networking.wifiEnabled ? "Turn on Wi-Fi above to search for networks." : "Click 'Scan for Networks' or check your router."
                    color: Colors.color(7)
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSizeSmall
                }
            }
        }
    }
}
