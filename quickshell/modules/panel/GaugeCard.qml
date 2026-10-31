import QtQuick
import QtQuick.Layouts
import qs.config
import qs.config.components

Rectangle {
    id: root
    property string icon: ""
    property string label: ""
    property real value: 0
    property real maximum: 100
    property string unit: "%"
    property color accent: "#89b4fa"

    radius: 16
    color: Qt.rgba(1, 1, 1, 0.045)
    border.width: 1
    border.color: Qt.rgba(1, 1, 1, 0.05)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 5
        Text { text: root.icon; color: root.accent; font.family: Appearance.iconFont; font.pixelSize: 19 }
        Text { text: root.label; color: Colors.color(7); font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSizeSmall; Layout.fillWidth: true; elide: Text.ElideRight }
        RowLayout {
            Layout.fillWidth: true
            spacing: 3
            Text { text: root.value < 0 ? "N/A" : Number(root.value).toFixed(0); color: Colors.foreground; font.family: Appearance.fontFamily; font.pixelSize: root.value < 0 ? 17 : 23; font.bold: true }
            Text { text: root.unit; color: Colors.color(7); font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSizeSmall; Layout.alignment: Qt.AlignBottom }
        }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 4
            radius: 2
            color: Qt.rgba(1, 1, 1, 0.10)
            Rectangle { width: parent.width * Math.max(0, Math.min(1, root.value / Math.max(1, root.maximum))); height: parent.height; radius: parent.radius; color: root.accent }
        }
        Item { Layout.fillHeight: true }
    }
}
