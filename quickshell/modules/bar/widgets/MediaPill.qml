import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import qs.config
import qs.config.components
import qs.services

RowLayout {
    id: root
    spacing: 8
    visible: player !== null && player.playbackState === MprisPlaybackState.Playing

    readonly property MprisPlayer player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
    readonly property string title: player?.trackTitle ?? ""
    readonly property string artist: player?.trackArtist ?? ""

    Text {
        text: root.player?.playbackState === MprisPlaybackState.Playing ? "󰏤" : "󰐊"
        color: Colors.color(4)
        font.family: Appearance.iconFont
        font.pixelSize: 13
        font.bold: true

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.player?.togglePlaying()
        }
    }

    Text {
        id: titleText
        text: (root.artist ? root.artist + " - " : "") + root.title
        color: Colors.textMain
        font.family: Appearance.fontFamily
        font.pixelSize: 12
        font.weight: Font.Medium
        elide: Text.ElideRight
        Layout.maximumWidth: 160
    }

    CavaVisualizer {
        barCount: 8
        maxHeight: 14
        barWidth: 2
        barColor: Colors.color(4)
    }
}
