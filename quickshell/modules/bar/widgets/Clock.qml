import QtQuick
import Quickshell.Io
import qs.config

Text {
    id: root
    color: Colors.foreground
    font.family: Appearance.fontFamily
    font.pixelSize: Appearance.fontSize + 1
    font.bold: true
    font.weight: Font.Bold

    property bool showDate: false
    property string timeText: ""
    property string dateText: ""
    text: root.showDate ? root.dateText : root.timeText

    Process {
        id: timeProc
        command: ["sh", "-c", "date '+%I:%M' && date '+%H'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n");
                const hm = lines[0];
                const h24 = Number(lines[1]);
                root.timeText = hm + " " + (h24 >= 12 ? "PM" : "AM");
            }
        }
    }

    Process {
        id: dateProc
        command: ["date", "+%a, %d %b"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: root.dateText = this.text.trim()
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            timeProc.running = true;
            if (root.showDate)
                dateProc.running = true;
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.showDate = !root.showDate;
            if (root.showDate)
                dateProc.running = true;
        }
    }
}
