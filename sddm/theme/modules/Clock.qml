import QtQuick 2.15
import QtQuick.Layouts 1.15

import ".."

Item {
    id: root

    property string clockText: ""
    property string dateString: ""

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            const now = new Date();

            root.clockText = Qt.formatTime(now, "hh:mm AP");
            root.dateString = Qt.formatDate(now, "dddd, MMMM d");
        }
    }

    ColumnLayout {
        anchors.centerIn: parent

        anchors.verticalCenterOffset: -150

        spacing: 10

        Text {
            text: root.clockText

            color: Theme.fg

            font.family: Theme.fontFamily
            font.pixelSize: 74
            font.bold: true

            Layout.alignment: Qt.AlignHCenter
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter

            radius: 999
            color: Qt.rgba(1, 1, 1, 0.06)
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.10)

            implicitWidth: dateLabel.implicitWidth + 26
            implicitHeight: dateLabel.implicitHeight + 10

            Text {
                id: dateLabel
                anchors.centerIn: parent

                text: root.dateString

                color: Theme.muted

                font.family: Theme.fontFamily
                font.pixelSize: 13
            }
        }
    }
}
