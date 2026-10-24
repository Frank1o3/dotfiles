import QtQuick
import qs.config

Item {
    id: root
    property real from: 0
    property real to: 1
    property real value: 0
    property string icon: ""
    signal moved(real value)

    implicitHeight: 36
    readonly property real ratio: Math.max(0, Math.min(1, (value - from) / (to - from)))
    readonly property color accentColor: Colors.color(4)

    // Outer pill track
    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: Qt.rgba(1, 1, 1, 0.08)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.12)
        clip: true

        // Filled active progress
        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: Math.max(track.height, parent.width * root.ratio)
            radius: track.radius
            color: root.accentColor
            opacity: 0.85

            Behavior on width {
                enabled: !sliderMouse.pressed
                NumberAnimation { duration: Appearance.animFast }
            }
        }

        // Icon inside track on left
        Text {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            text: root.icon
            color: root.ratio > 0.15 ? Colors.background : Colors.foreground
            font.family: Appearance.iconFont
            font.pixelSize: 15
            font.bold: true
            z: 2
        }

        // Percentage label on right
        Text {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            text: Math.round(root.ratio * 100) + "%"
            color: root.ratio > 0.85 ? Colors.background : Colors.foreground
            font.family: Appearance.fontFamily
            font.pixelSize: 11
            font.weight: Font.DemiBold
            z: 2
        }

        MouseArea {
            id: sliderMouse
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true

            onPositionChanged: mouse => {
                if (pressed) update(mouse.x);
            }
            onPressed: mouse => update(mouse.x)

            function update(x) {
                const r = Math.max(0, Math.min(1, x / track.width));
                root.value = root.from + r * (root.to - root.from);
                root.moved(root.value);
            }
        }
    }
}
