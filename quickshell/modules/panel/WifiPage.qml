import QtQuick
import QtQuick.Layouts
import Quickshell.Networking
import qs.config
import qs.config.components

ColumnLayout {
    id: root
    spacing: 12
    readonly property var device: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    property var selectedNetwork: null
    property string errorMessage: ""

    Component.onCompleted: if (device && Networking.wifiEnabled) device.scannerEnabled = true

    RowLayout {
        Layout.fillWidth: true
        Text { text: "Wi-Fi"; color: Colors.foreground; font.family: Appearance.fontFamily; font.pixelSize: 20; font.bold: true; Layout.fillWidth: true }
        GlassSwitch { checked: Networking.wifiEnabled; onToggled: value => Networking.wifiEnabled = value }
    }
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 40
        radius: 12
        color: Qt.rgba(1, 1, 1, 0.055)
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            Text { text: "󰤨"; color: Colors.color(4); font.family: Appearance.iconFont; font.pixelSize: 17 }
            Text { text: "Scan for networks"; color: Colors.foreground; font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSize; Layout.fillWidth: true }
            Text { text: root.device?.scannerEnabled ? "Scanning" : "Refresh"; color: Colors.color(4); font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSizeSmall }
        }
        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: if (root.device) root.device.scannerEnabled = true }
    }

    Text {
        Layout.fillWidth: true
        Layout.preferredHeight: root.device && Networking.wifiEnabled && root.device.networks.values.length > 0 ? 0 : 86
        visible: !root.device || !Networking.wifiEnabled || root.device.networks.values.length === 0
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.Wrap
        color: Colors.color(7)
        font.family: Appearance.fontFamily
        font.pixelSize: Appearance.fontSize
        text: !Networking.wifiEnabled
            ? "Wi-Fi is turned off. Turn it on to scan for networks."
            : !root.device
                ? "No Wi-Fi adapter is available. Check the device and NetworkManager."
                : "No networks found. Try scanning again."
    }

    ListView {
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(contentHeight, 244)
        visible: root.device && Networking.wifiEnabled && root.device.networks.values.length > 0
        clip: true
        spacing: 6
        model: visible ? root.device.networks.values : []
        delegate: Rectangle {
            required property var modelData
            width: ListView.view.width
            height: 54
            radius: 12
            color: modelData.connected ? Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.14) : Qt.rgba(1, 1, 1, 0.045)
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 10
                spacing: 8
                Text { text: modelData.connected ? "󰤨" : "󰤯"; color: modelData.connected ? Colors.color(4) : Colors.color(7); font.family: Appearance.iconFont; font.pixelSize: 18 }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1
                    Text { text: modelData.name || "Hidden network"; color: Colors.foreground; font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSize; font.bold: true; elide: Text.ElideRight; Layout.fillWidth: true }
                    Text { text: modelData.connected ? "Connected" : (modelData.known ? "Saved network" : `${Math.round((modelData.signalStrength ?? 0) * 100)}% signal`); color: Colors.color(7); font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSizeSmall }
                }
                GlassButton {
                    text: modelData.connected ? "Online" : "Connect"
                    accent: modelData.connected
                    onClicked: {
                        if (modelData.connected) return;
                        root.errorMessage = "";
                        if (modelData.known || modelData.security === WifiSecurityType.Open || modelData.security === WifiSecurityType.Owe)
                            modelData.connect();
                        else root.selectedNetwork = modelData;
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

    Text {
        Layout.fillWidth: true
        visible: root.errorMessage.length > 0
        text: root.errorMessage
        color: "#f38ba8"
        font.family: Appearance.fontFamily
        font.pixelSize: Appearance.fontSizeSmall
        wrapMode: Text.Wrap
    }

    Rectangle {
        Layout.fillWidth: true
        visible: root.selectedNetwork !== null
        implicitHeight: visible ? 90 : 0
        radius: 12
        color: Qt.rgba(1, 1, 1, 0.07)
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 6
            Text { text: `Connect to ${root.selectedNetwork?.name ?? "network"}`; color: Colors.foreground; font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSize; font.bold: true }
            RowLayout {
                Layout.fillWidth: true
                TextInput {
                    id: psk
                    Layout.fillWidth: true
                    color: Colors.foreground
                    font.family: Appearance.fontFamily
                    echoMode: TextInput.Password
                    clip: true
                    Text { anchors.fill: parent; text: "Network password"; color: Colors.color(7); visible: !parent.text && !parent.activeFocus; font: parent.font }
                }
                GlassButton { text: "Connect"; accent: true; onClicked: { root.errorMessage = ""; root.selectedNetwork.connectWithPsk(psk.text); psk.text = ""; root.selectedNetwork = null } }
                GlassButton { text: "Cancel"; onClicked: root.selectedNetwork = null }
            }
        }
    }
}
