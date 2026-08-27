import QtQuick
import Quickshell
import Quickshell.Io
import qs.config

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
        // ships alongside the bar module — see note below
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
        onTriggered: proc.running = true
    }
}
