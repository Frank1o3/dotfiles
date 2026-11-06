import QtQuick
import qs.config

Item {
    id: root
    signal clicked
    property string text: ""
    property string icon: ""
    property bool accent: false
    activeFocusOnTab: true

    Keys.onReturnPressed: root.clicked()
    Keys.onEnterPressed: root.clicked()
    Keys.onSpacePressed: root.clicked()

    implicitWidth: label.implicitWidth + (root.icon.length > 0 ? 28 : 20) + 20
    implicitHeight: 34

    Rectangle {
        id: surface
        anchors.fill: parent
        radius: Appearance.radiusMedium
        color: root.accent
            ? Colors.accentColor
            : mouse.containsMouse ? Colors.surfaceHover : Colors.surfaceSubtle
        border.width: root.activeFocus && !root.accent ? 1 : 0
        border.color: Colors.accentOutline
        Behavior on color { ColorAnimation { duration: Appearance.animFast } }

        Row {
            anchors.centerIn: parent
            spacing: 7

            Text {
                visible: root.icon.length > 0
                text: root.icon
                color: root.accent ? Colors.backgroundColor : Colors.foregroundColor
                font.family: Appearance.iconFont
                font.pixelSize: Appearance.fontSize
                font.weight: Font.Bold
            }
            Text {
                id: label
                text: root.text
                color: root.accent ? Colors.backgroundColor : Colors.foregroundColor
                font.family: Appearance.fontFamily
                font.pixelSize: Appearance.fontSizeSmall + 1
                font.weight: Font.DemiBold
            }
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
