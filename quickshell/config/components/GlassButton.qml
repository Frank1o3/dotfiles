import QtQuick
import qs.config

Item {
    id: root
    signal clicked
    property string text: ""
    property string icon: ""
    property bool accent: false

    implicitWidth: label.implicitWidth + (root.icon.length > 0 ? 28 : 20) + 20
    implicitHeight: 32

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: root.accent ? Colors.color(4) : (mouse.containsMouse ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(1, 1, 1, 0.05))
        border.width: root.accent ? 0 : 1
        border.color: Qt.rgba(1, 1, 1, 0.08)
        Behavior on color {
            ColorAnimation {
                duration: Appearance.animFast
            }
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: 6
        Text {
            visible: root.icon.length > 0
            text: root.icon
            color: root.accent ? Colors.background : Colors.foreground
            font.family: Appearance.fontFamily
            font.pixelSize: Appearance.fontSize
            font.weight: Font.Bold
        }
        Text {
            id: label
            text: root.text
            color: root.accent ? Colors.background : Colors.foreground
            font.family: Appearance.fontFamily
            font.pixelSize: Appearance.fontSize
            font.bold: root.accent
            font.weight: Font.Bold
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
