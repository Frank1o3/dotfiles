import QtQuick
import Quickshell.Io
import qs.config

Text {
    id: root
    color: Colors.color(2)
    font.family: Appearance.fontFamily
    font.pixelSize: Appearance.fontSize
    font.weight: Font.Bold
    text: "  " + temp + "°C"

    property real temp: 0

    Process {
        id: proc
        // ← same hwmon path you had in waybar/config.jsonc, update if it drifts
        command: ["cat", "/sys/class/hwmon/hwmon2/temp1_input"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.temp = Math.round(Number(this.text.trim()) / 1000)
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: proc.running = true
    }
}
