pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

Singleton {
    id: root

    property var values: [10, 15, 25, 40, 35, 20, 15, 10]
    readonly property bool isPlaying: Mpris.players.values.some(p => p.playbackState === MprisPlaybackState.Playing)

    Process {
        id: proc
        command: ["sh", `${Quickshell.env("HOME")}/.config/quickshell/scripts/cava.sh`]
        running: true

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: line => {
                if (!line) return;
                const parts = line.split(";").filter(Boolean);
                if (parts.length >= 8) {
                    root.values = parts.slice(0, 8).map(v => Math.min(100, Math.max(4, parseInt(v, 10) || 4)));
                }
            }
        }
    }
}
