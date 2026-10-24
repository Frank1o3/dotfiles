import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services

Row {
    id: root
    spacing: 3
    property int barCount: 8
    property int maxHeight: 18
    property int barWidth: 3
    property color barColor: Colors.color(4)
    property bool active: Cava.isPlaying

    Repeater {
        model: root.barCount
        Rectangle {
            required property int index
            width: root.barWidth
            radius: root.barWidth / 2
            color: root.barColor
            opacity: root.active ? 0.9 : 0.35

            readonly property real targetHeight: {
                if (!root.active) return 3;
                const val = Cava.values[index] || 10;
                return Math.max(3, (val / 100) * root.maxHeight);
            }

            height: targetHeight

            Behavior on height {
                NumberAnimation {
                    duration: 80
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}
