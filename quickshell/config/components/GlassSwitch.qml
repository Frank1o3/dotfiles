import QtQuick
import qs.config

Item {
    id: root
    property bool checked: false
    signal toggled(bool checked)
    activeFocusOnTab: true

    Keys.onReturnPressed: root.toggled(!root.checked)
    Keys.onEnterPressed: root.toggled(!root.checked)
    Keys.onSpacePressed: root.toggled(!root.checked)

    implicitWidth: 44
    implicitHeight: 24

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? Colors.accentColor : Colors.surfaceRaised
        border.width: 1
        border.color: root.activeFocus ? Colors.accentOutline : Colors.outline
        Behavior on color {
            ColorAnimation {
                duration: Appearance.animFast
            }
        }
    }

    Rectangle {
        width: parent.height - 6
        height: parent.height - 6
        radius: width / 2
        color: root.checked ? Colors.background : Colors.foreground
        y: 3
        x: root.checked ? parent.width - width - 3 : 3
        Behavior on x {
            NumberAnimation {
                duration: Appearance.animFast
                easing.type: Easing.OutCubic
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.toggled(!root.checked);
        }
    }
}
