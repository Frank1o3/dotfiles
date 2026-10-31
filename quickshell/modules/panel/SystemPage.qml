import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.config
import qs.modules.panel
import qs.services

ColumnLayout {
    id: root
    spacing: 12
    property int memory: -1
    property int temperature: -1
    property int disk: -1

    Process {
        id: statsProc
        command: ["sh", "-c", "awk '/MemTotal:/ {t=$2} /MemAvailable:/ {a=$2} END {if (t) printf \"%d\\n\", (1-a/t)*100; else print -1}' /proc/meminfo; df -P / | awk 'NR==2 {gsub(/%/,\"\",$5); print $5}'; found=0; for f in /sys/class/hwmon/hwmon*/temp*_input; do [ -r \"$f\" ] || continue; n=$(cat \"${f%_input}_label\" 2>/dev/null); case \"$n\" in *CPU*|*Package*|*Tctl*) awk '{printf \"%d\\n\", $1/1000}' \"$f\"; found=1; break;; esac; done; [ $found -eq 1 ] || echo -1"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n");
                if (lines.length >= 3) {
                    root.memory = Number(lines[0]) || 0;
                    root.disk = Number(lines[1]) || 0;
                    root.temperature = Number(lines[2]) || 0;
                }
            }
        }
    }
    Timer { interval: 3000; running: !GameMode.active; repeat: true; onTriggered: if (!statsProc.running) statsProc.running = true }

    Text { text: "System Monitor"; color: Colors.foreground; font.family: Appearance.fontFamily; font.pixelSize: 20; font.bold: true }
    Text { text: GameMode.active ? "Game Mode · background sampling paused" : "Live hardware overview"; color: Colors.color(7); font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSizeSmall; Layout.topMargin: -9 }
    GridLayout {
        Layout.fillWidth: true
        columns: 2
        rowSpacing: 8
        columnSpacing: 8
        GaugeCard { Layout.fillWidth: true; Layout.preferredHeight: 128; icon: "󰍛"; label: "CPU"; value: SysMonitor.cpuUsage; unit: "%"; accent: SysMonitor.cpuUsage > 85 ? "#f38ba8" : Colors.color(1) }
        GaugeCard { Layout.fillWidth: true; Layout.preferredHeight: 128; icon: "󰘚"; label: "Memory"; value: root.memory; unit: "%"; accent: root.memory > 85 ? "#f38ba8" : Colors.color(4) }
        GaugeCard { Layout.fillWidth: true; Layout.preferredHeight: 128; icon: "󰢮"; label: "Integrated GPU"; value: SysMonitor.igpuUsage; unit: "%"; accent: Colors.color(2) }
        GaugeCard { Layout.fillWidth: true; Layout.preferredHeight: 128; icon: "󰔄"; label: "CPU temperature"; value: root.temperature; unit: "°C"; maximum: 100; accent: root.temperature >= 85 ? "#f38ba8" : Colors.color(3) }
        GaugeCard { Layout.fillWidth: true; Layout.preferredHeight: 128; icon: "󰋊"; label: "Root disk"; value: root.disk; unit: "% used"; accent: root.disk >= 90 ? "#f38ba8" : Colors.color(5) }
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 128
            radius: 16
            color: Qt.rgba(1, 1, 1, 0.045)
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 6
                Text { text: GameMode.active ? "󰊴" : "󰓅"; color: Colors.color(4); font.family: Appearance.iconFont; font.pixelSize: 26; Layout.alignment: Qt.AlignHCenter }
                Text { text: GameMode.active ? "Performance" : "Balanced"; color: Colors.foreground; font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSize; Layout.alignment: Qt.AlignHCenter }
            }
        }
    }
}
