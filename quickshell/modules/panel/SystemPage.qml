import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Services.UPower
import qs.config
import qs.modules.panel
import qs.services

ColumnLayout {
    id: root
    spacing: 12

    property int memory: -1
    property string memoryUsed: ""
    property string memoryTotal: ""
    property int temperature: -1
    property int disk: -1

    readonly property UPowerDevice bat: UPower.displayDevice

    Process {
        id: statsProc
        command: ["sh", "-c", "awk '/MemTotal:/ {t=$2} /MemAvailable:/ {a=$2} END {if (t) printf \"%d\\n%0.1f\\n%0.1f\\n\", (1-a/t)*100, (t-a)/1024/1024, t/1024/1024; else print \"-1\\n0\\n0\"}' /proc/meminfo; df -P / | awk 'NR==2 {gsub(/%/,\"\",$5); print $5}'; found=0; for f in /sys/class/hwmon/hwmon*/temp*_input; do [ -r \"$f\" ] || continue; n=$(cat \"${f%_input}_label\" 2>/dev/null); case \"$n\" in *CPU*|*Package*|*Tctl*) awk '{printf \"%d\\n\", $1/1000}' \"$f\"; found=1; break;; esac; done; [ $found -eq 1 ] || echo -1"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n");
                if (lines.length >= 5) {
                    root.memory = Number(lines[0]) || 0;
                    root.memoryUsed = lines[1] + " GB";
                    root.memoryTotal = lines[2] + " GB";
                    root.disk = Number(lines[3]) || 0;
                    root.temperature = Number(lines[4]) || 0;
                }
            }
        }
    }

    Timer {
        interval: 3000
        running: !GameMode.active
        repeat: true
        onTriggered: if (!statsProc.running) statsProc.running = true
    }

    RowLayout {
        Layout.fillWidth: true
        Text {
            text: GameMode.active ? "Game Mode · background hardware sampling paused" : "Live hardware analytics"
            color: Colors.color(7)
            font.family: Appearance.fontFamily
            font.pixelSize: Appearance.fontSizeSmall
            Layout.fillWidth: true
        }

        Text {
            text: "Auto-Refresh: 3s"
            color: Colors.color(7)
            font.family: Appearance.fontFamily
            font.pixelSize: 10
        }
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 2
        rowSpacing: 8
        columnSpacing: 8

        GaugeCard {
            Layout.fillWidth: true
            Layout.preferredHeight: 128
            icon: "󰍛"
            label: "CPU Usage"
            value: SysMonitor.cpuUsage
            unit: "%"
            accent: SysMonitor.cpuUsage > 85 ? Colors.danger : Colors.color(1)
        }

        GaugeCard {
            Layout.fillWidth: true
            Layout.preferredHeight: 128
            icon: "󰘚"
            label: root.memoryUsed ? `Memory (${root.memoryUsed} / ${root.memoryTotal})` : "Memory"
            value: root.memory
            unit: "%"
            accent: root.memory > 85 ? Colors.danger : Colors.color(4)
        }

        GaugeCard {
            Layout.fillWidth: true
            Layout.preferredHeight: 128
            icon: "󰢮"
            label: "Integrated GPU"
            value: SysMonitor.igpuUsage
            unit: "%"
            accent: Colors.color(2)
        }

        GaugeCard {
            Layout.fillWidth: true
            Layout.preferredHeight: 128
            icon: "󰔄"
            label: "CPU Temperature"
            value: root.temperature
            unit: "°C"
            maximum: 100
            accent: root.temperature >= 85 ? Colors.danger : Colors.color(3)
        }

        GaugeCard {
            Layout.fillWidth: true
            Layout.preferredHeight: 128
            icon: "󰋊"
            label: "Root Storage (/)"
            value: root.disk
            unit: "% used"
            accent: root.disk >= 90 ? Colors.danger : Colors.color(5)
        }

        // Performance / Battery Card
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 128
            radius: 16
            color: Colors.surfaceSubtle
            border.width: 1
            border.color: Colors.outline

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    text: root.bat?.isLaptopBattery
                        ? (root.bat.state === UPowerDeviceState.Charging ? "󰂄" : "󰁹")
                        : (GameMode.active ? "󰊴" : "󰓅")
                    color: Colors.color(4)
                    font.family: Appearance.iconFont
                    font.pixelSize: 28
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: root.bat?.isLaptopBattery
                        ? `${Math.round(root.bat.percentage * 100)}% · ${root.bat.state === UPowerDeviceState.Charging ? 'Charging' : 'Discharging'}`
                        : (GameMode.active ? "Performance Mode" : "Balanced Profile")
                    color: Colors.foreground
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSize
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: root.bat?.isLaptopBattery
                        ? (root.bat.changeRate > 0 ? `${root.bat.changeRate.toFixed(1)} W rate` : (root.bat.healthPercentage ? `${root.bat.healthPercentage}% health` : "Battery OK"))
                        : (GameMode.active ? "Prioritizing game framerates" : "CPU governor: auto-cpufreq")
                    color: Colors.color(7)
                    font.family: Appearance.fontFamily
                    font.pixelSize: 11
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
}
