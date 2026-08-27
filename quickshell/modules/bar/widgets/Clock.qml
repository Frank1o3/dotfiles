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

    Process {
        id: proc
        command: ["date", "+%I:%M %p"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.text = this.text.trim()
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: proc.running = true
    }
}
