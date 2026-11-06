pragma Singleton
import Quickshell
import Quickshell.Io
import qs.services

Singleton {
    id: root

    property int cpuUsage: 0
    property int igpuUsage: -1
    property int memoryUsage: 0
    property int diskUsage: 0

    Process {
        id: proc
        command: [`${Quickshell.env("HOME")}/.config/quickshell/scripts/sysmon.sh`]
        running: !GameMode.active

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: line => {
                try {
                    const data = JSON.parse(line);
                    root.cpuUsage = data.cpu;
                    root.igpuUsage = data.igpu;
                    root.memoryUsage = data.memory;
                    root.diskUsage = data.disk;
                } catch (e) {}
            }
        }
    }
}
