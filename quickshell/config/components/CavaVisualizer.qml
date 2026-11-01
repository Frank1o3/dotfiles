import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services

Row {
    id: root
    spacing: 3
    height: root.maxHeight
    property int barCount: 8
    property int maxHeight: 18
    property int barWidth: 3
    property color barColor: Colors.color(4)
    property bool active: Cava.isPlaying && !GameMode.active

    Repeater {
        model: root.barCount
        Item {
            required property int index
            width: root.barWidth
            height: root.maxHeight

            readonly property real targetHeight: {
                if (!root.active) return 3;
                const val = Cava.values[index] || 10;
                return Math.max(3, (val / 100) * root.maxHeight);
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: parent.targetHeight
                radius: root.barWidth / 2
                color: root.barColor
                opacity: root.active ? 0.9 : 0.35

                Behavior on height {
                    NumberAnimation {
                        duration: Appearance.animFast
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
    }
}
