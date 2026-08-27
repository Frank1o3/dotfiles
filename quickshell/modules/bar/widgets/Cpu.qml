import QtQuick
import Quickshell.Io
import qs.config

Text {
    id: root
    property int usage: 0
    property real prevIdle: 0
    property real prevTotal: 0

    color: Colors.color(1)
    font.family: Appearance.fontFamily
    font.pixelSize: Appearance.fontSize
    font.weight: Font.Bold
    text: "󰍛 " + usage + "%"

    Process {
        id: proc
        command: ["sh", "-c", "grep '^cpu ' /proc/stat"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.trim().split(/\s+/).slice(1).map(Number);
                const idle = parts[3] + parts[4];
                const total = parts.reduce((a, b) => a + b, 0);
                const dIdle = idle - root.prevIdle;
                const dTotal = total - root.prevTotal;

                if (root.prevTotal > 0 && dTotal > 0) {
                    root.usage = Math.round((1 - dIdle / dTotal) * 100);
                }
                root.prevIdle = idle;
                root.prevTotal = total;
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: proc.running = true
    }
}
