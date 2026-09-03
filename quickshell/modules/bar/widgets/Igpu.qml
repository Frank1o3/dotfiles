import QtQuick
import Quickshell
import Quickshell.Io
import qs.config
import qs.services

Text {
    id: root
    color: Colors.color(1)
    font.family: Appearance.fontFamily
    font.pixelSize: Appearance.fontSize
    font.weight: Font.Bold
    text: "󰢮 " + value

    property string value: "--"

    Process {
        id: proc
        command: [`${Quickshell.env("HOME")}/.config/quickshell/scripts/igpu.sh`]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.value = this.text.trim()
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: if (!GameMode.active)
            proc.running = true
    }
}
