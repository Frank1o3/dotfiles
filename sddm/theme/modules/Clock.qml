import QtQuick
import QtQuick.Layouts

import ".."

Item {
    id: root

    property string clockText: ""
    property string dateText: ""

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            const now = new Date();

            root.clockText = Qt.formatTime(now, "hh:mm AP");

            root.dateText = Qt.formatDate(now, "dddd, MMMM d");
        }
    }

    ColumnLayout {
        anchors.centerIn: parent

        anchors.verticalCenterOffset: -140

        spacing: 6

        Text {
            text: root.clockText

            color: Theme.fg

            font.family: Theme.fontFamily
            font.pixelSize: 72
            font.bold: true

            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: root.dateText

            color: Theme.fg
            opacity: 0.8

            font.family: Theme.fontFamily
            font.pixelSize: 18

            Layout.alignment: Qt.AlignHCenter
        }
    }
}
