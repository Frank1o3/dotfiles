import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import qs.config
import qs.config.components

ColumnLayout {
    id: root
    spacing: 12
    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter

    RowLayout {
        Layout.fillWidth: true
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            Text { text: "Bluetooth"; color: Colors.foreground; font.family: Appearance.fontFamily; font.pixelSize: 20; font.bold: true }
            Text { text: root.adapter?.name ?? "No Bluetooth adapter"; color: Colors.color(7); font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSizeSmall }
        }
        GlassSwitch { checked: root.adapter?.enabled ?? false; onToggled: value => { if (root.adapter) root.adapter.enabled = value } }
    }

    RowLayout {
        Layout.fillWidth: true
        GlassButton { Layout.fillWidth: true; text: (root.adapter?.discoverable ?? false) ? "Discoverable" : "Make discoverable"; onClicked: if (root.adapter) { root.adapter.discoverableTimeout = 120; root.adapter.discoverable = !root.adapter.discoverable } }
        GlassButton { Layout.fillWidth: true; text: (root.adapter?.pairable ?? false) ? "Pairing on" : "Enable pairing"; onClicked: if (root.adapter) { root.adapter.pairableTimeout = 120; root.adapter.pairable = !root.adapter.pairable } }
    }

    ListView {
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(contentHeight, 250)
        visible: root.adapter?.enabled && (root.adapter?.devices.values.length ?? 0) > 0
        clip: true
        spacing: 6
        model: visible ? root.adapter.devices.values : []
        delegate: Rectangle {
            required property var modelData
            width: ListView.view.width
            height: 52
            radius: 12
            color: Qt.rgba(1, 1, 1, 0.045)
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 10
                spacing: 8
                Text { text: modelData.connected ? "󰂱" : "󰂯"; color: modelData.connected ? Colors.color(4) : Colors.color(7); font.family: Appearance.iconFont; font.pixelSize: 18 }
                Text { text: modelData.name; color: Colors.foreground; font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSize; Layout.fillWidth: true; elide: Text.ElideRight }
                GlassButton {
                    text: modelData.pairing ? "Pairing…" : (modelData.connected ? "Disconnect" : (modelData.paired ? "Connect" : "Pair"))
                    onClicked: {
                        if (modelData.pairing) return;
                        if (modelData.connected) modelData.disconnect();
                        else if (modelData.paired) modelData.connect();
                        else modelData.pair();
                    }
                }
            }
        }
    }

    Text {
        Layout.fillWidth: true
        Layout.preferredHeight: 82
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.Wrap
        color: Colors.color(7)
        font.family: Appearance.fontFamily
        font.pixelSize: Appearance.fontSize
        visible: !root.adapter || !root.adapter.enabled || (root.adapter.devices.values.length === 0)
        text: !root.adapter
            ? "No Bluetooth adapter is available. Check that BlueZ and its D-Bus service are running."
            : !root.adapter.enabled
                ? "Turn on Bluetooth to manage paired devices."
                : "No paired devices yet. Put your device in pairing mode and use the system pairing prompt."
    }
}
