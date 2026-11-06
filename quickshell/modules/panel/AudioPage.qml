import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import qs.config
import qs.config.components
import qs.services

ColumnLayout {
    id: root
    spacing: 12

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    // Multi-player MPRIS support
    readonly property var players: Mpris.players.values
    property int selectedPlayerIndex: 0
    readonly property MprisPlayer player: (players.length > 0 && selectedPlayerIndex < players.length)
        ? players[selectedPlayerIndex]
        : (players.length > 0 ? players[0] : null)

    // Track active pipewire objects
    readonly property var sinks: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream)
    readonly property var streams: Pipewire.nodes.values.filter(n => n.isStream && n.audio)
    PwObjectTracker {
        objects: [root.sink, root.source].concat(root.sinks).concat(root.streams)
    }

    function formatTime(microseconds) {
        if (!microseconds || isNaN(microseconds) || microseconds <= 0) return "0:00";
        const totalSeconds = Math.floor(microseconds / 1000000);
        const mins = Math.floor(totalSeconds / 60);
        const secs = totalSeconds % 60;
        return `${mins}:${secs < 10 ? "0" : ""}${secs}`;
    }

    // Header row with title & player selector
    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        Text {
            text: "Audio & Media"
            color: Colors.foreground
            font.family: Appearance.fontFamily
            font.pixelSize: Appearance.fontSize + 2
            font.bold: true
        }

        Item { Layout.fillWidth: true }

        // Player switcher pills if multiple media players exist
        Row {
            spacing: 6
            visible: root.players.length > 1

            Repeater {
                model: root.players
                delegate: Rectangle {
                    required property var modelData
                    required property int index

                    width: playerTabContent.implicitWidth + 14
                    height: 26
                    radius: 13
                    color: root.selectedPlayerIndex === index
                        ? Colors.accentSurface
                        : Colors.surfaceSubtle
                    border.width: 1
                    border.color: root.selectedPlayerIndex === index
                        ? Colors.color(4)
                        : Colors.outline

                    Row {
                        id: playerTabContent
                        anchors.centerIn: parent
                        spacing: 5
                        Text {
                            text: modelData.playbackState === MprisPlaybackState.Playing ? "󰎆" : "󰏤"
                            color: root.selectedPlayerIndex === index ? Colors.color(4) : Colors.color(7)
                            font.family: Appearance.iconFont
                            font.pixelSize: 11
                        }
                        Text {
                            text: modelData.identity || `Player ${index + 1}`
                            color: root.selectedPlayerIndex === index ? Colors.foreground : Colors.color(7)
                            font.family: Appearance.fontFamily
                            font.pixelSize: 10
                            font.bold: root.selectedPlayerIndex === index
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.selectedPlayerIndex = index
                    }
                }
            }
        }
    }

    // Media Player Card
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: mediaContent.implicitHeight + 24
        radius: Appearance.radiusLarge
        color: Colors.surfaceSubtle
        border.width: 1
        border.color: Colors.outline

        ColumnLayout {
            id: mediaContent
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                spacing: 14

                // Album art or music icon
                Rectangle {
                    Layout.preferredWidth: 84
                    Layout.preferredHeight: 84
                    radius: 14
                    color: Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.16)
                    border.width: 1
                    border.color: Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.3)
                    clip: true

                    Image {
                        anchors.fill: parent
                        visible: !!root.player?.trackArtUrl
                        source: root.player?.trackArtUrl ?? ""
                        fillMode: Image.PreserveAspectCrop
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: !root.player?.trackArtUrl
                        text: root.player ? "󰎆" : "󰝛"
                        color: Colors.color(4)
                        font.family: Appearance.iconFont
                        font.pixelSize: 32
                    }
                }

                // Track details & main controls
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            Layout.fillWidth: true
                            text: root.player?.trackTitle || (root.player ? "Playing" : "No active media playback")
                            color: Colors.foreground
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSize + 1
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        // Visualizer
                        CavaVisualizer {
                            visible: root.player?.playbackState === MprisPlaybackState.Playing
                            barCount: 10
                            maxHeight: 18
                            barWidth: 3
                            barColor: Colors.color(4)
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: (root.player?.trackArtist ? root.player.trackArtist : "") +
                              (root.player?.trackAlbum ? ` · ${root.player.trackAlbum}` : "") ||
                              (root.player ? (root.player.identity || "Media Player") : "Play audio in any application to control it here")
                        color: Colors.color(7)
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSizeSmall
                        elide: Text.ElideRight
                    }

                    Item { Layout.preferredHeight: 4 }

                    // Media control buttons row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        visible: !!root.player

                        // Shuffle Button
                        Rectangle {
                            visible: root.player?.shuffleSupported ?? false
                            width: 28; height: 28; radius: 14
                            color: root.player?.shuffle ? Colors.accentSurface : Colors.surfaceSubtle
                            Text {
                                anchors.centerIn: parent
                                text: "󰒝"
                                color: root.player?.shuffle ? Colors.color(4) : Colors.textMuted
                                font.family: Appearance.iconFont
                                font.pixelSize: 13
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: if (root.player) root.player.shuffle = !root.player.shuffle
                            }
                        }

                        // Previous
                        Rectangle {
                            width: 32; height: 32; radius: 16
                            color: prevMouse.containsMouse ? Colors.surfaceHover : Colors.surfaceSubtle
                            Text { anchors.centerIn: parent; text: "󰒮"; color: Colors.foreground; font.family: Appearance.iconFont; font.pixelSize: 14 }
                            MouseArea { id: prevMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.player?.previous() }
                        }

                        // Play / Pause
                        Rectangle {
                            width: 36; height: 36; radius: 18
                            color: Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.28)
                            border.width: 1
                            border.color: Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.5)
                            Text {
                                anchors.centerIn: parent
                                text: root.player?.playbackState === MprisPlaybackState.Playing ? "󰏤" : "󰐊"
                                color: Colors.foreground
                                font.family: Appearance.iconFont
                                font.pixelSize: 16
                            }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.player?.togglePlaying() }
                        }

                        // Next
                        Rectangle {
                            width: 32; height: 32; radius: 16
                            color: nextMouse.containsMouse ? Colors.surfaceHover : Colors.surfaceSubtle
                            Text { anchors.centerIn: parent; text: "󰒭"; color: Colors.foreground; font.family: Appearance.iconFont; font.pixelSize: 14 }
                            MouseArea { id: nextMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.player?.next() }
                        }

                        // Loop / Repeat mode
                        Rectangle {
                            visible: root.player?.loopSupported ?? false
                            width: 28; height: 28; radius: 14
                            readonly property bool isLooping: root.player?.loopState !== MprisLoopState.None
                            color: isLooping ? Colors.accentSurface : Colors.surfaceSubtle
                            Text {
                                anchors.centerIn: parent
                                text: root.player?.loopState === MprisLoopState.Track ? "󰑘" : "󰑖"
                                color: parent.isLooping ? Colors.color(4) : Colors.textMuted
                                font.family: Appearance.iconFont
                                font.pixelSize: 13
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (!root.player) return;
                                    if (root.player.loopState === MprisLoopState.None)
                                        root.player.loopState = MprisLoopState.Playlist;
                                    else if (root.player.loopState === MprisLoopState.Playlist)
                                        root.player.loopState = MprisLoopState.Track;
                                    else
                                        root.player.loopState = MprisLoopState.None;
                                }
                            }
                        }

                        Item { Layout.fillWidth: true }
                    }
                }
            }

            // Seek Bar (if track length is known & seek is supported)
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                visible: !!root.player && (root.player.length > 0 || root.player.positionSupported)

                Text {
                    text: root.formatTime(root.player?.position ?? 0)
                    color: Colors.color(7)
                    font.family: Appearance.fontFamily
                    font.pixelSize: 10
                }

                Rectangle {
                    id: seekTrack
                    Layout.fillWidth: true
                    height: 5
                    radius: 2.5
                    color: Colors.surfaceRaised

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: parent.width * Math.max(0, Math.min(1, (root.player?.position ?? 0) / Math.max(1, root.player?.length ?? 1)))
                        radius: parent.radius
                        color: Colors.color(4)
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: mouse => {
                            if (!root.player || !root.player.length || !root.player.canSeek) return;
                            const targetRatio = Math.max(0, Math.min(1, mouse.x / seekTrack.width));
                            const targetPos = targetRatio * root.player.length;
                            root.player.position = targetPos;
                        }
                    }
                }

                Text {
                    text: root.formatTime(root.player?.length ?? 0)
                    color: Colors.color(7)
                    font.family: Appearance.fontFamily
                    font.pixelSize: 10
                }
            }
        }
    }

    // Scrollable area for device controls & application volume streams
    ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        contentWidth: availableWidth

        ColumnLayout {
            width: parent.width
            spacing: 12

            // Output Devices & Master Volume
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: outputSection.implicitHeight + 28
                radius: Appearance.radiusLarge
                color: Colors.surfaceSubtle
                border.width: 1
                border.color: Colors.outline

                ColumnLayout {
                    id: outputSection
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "󰕾"; color: Colors.color(4); font.family: Appearance.iconFont; font.pixelSize: 16 }
                        Text {
                            text: "Output Device"
                            color: Colors.foreground
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSize
                            font.bold: true
                        }
                        Text {
                            Layout.fillWidth: true
                            text: root.sink?.description || root.sink?.name || "Default Output"
                            color: Colors.color(7)
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSizeSmall
                            elide: Text.ElideRight
                        }
                        Text {
                            text: `${Math.round((root.sink?.audio?.volume ?? 0) * 100)}%`
                            color: Colors.foreground
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSizeSmall
                            font.bold: true
                        }
                    }

                    // Master Volume Slider + Mute
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        GlassSlider {
                            Layout.fillWidth: true
                            icon: root.sink?.audio?.muted ? "󰝟" : "󰕾"
                            value: root.sink?.audio?.volume ?? 0
                            onMoved: val => { if (root.sink?.audio) root.sink.audio.volume = val }
                        }

                        GlassButton {
                            icon: root.sink?.audio?.muted ? "󰝟" : "󰕾"
                            text: root.sink?.audio?.muted ? "Unmute" : "Mute"
                            accent: root.sink?.audio?.muted
                            onClicked: if (root.sink?.audio) root.sink.audio.muted = !root.sink.audio.muted
                        }
                    }

                    // Available Sink Selection Chips
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        visible: root.sinks.length > 1

                        Text {
                            text: "Available Outputs:"
                            color: Colors.color(7)
                            font.family: Appearance.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                        }

                        Flow {
                            Layout.fillWidth: true
                            spacing: 6

                            Repeater {
                                model: root.sinks
                                delegate: Rectangle {
                                    required property var modelData
                                    readonly property bool isCurrent: root.sink?.id === modelData.id
                                    implicitWidth: sinkChipText.implicitWidth + 24
                                    implicitHeight: 26
                                    radius: 13
                                    color: isCurrent
                                        ? Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.24)
                                        : Colors.surfaceSubtle
                                    border.width: 1
                                    border.color: isCurrent ? Colors.accentOutline : Colors.outline

                                    Row {
                                        id: sinkChipText
                                        anchors.centerIn: parent
                                        spacing: 5
                                        Text {
                                            text: isCurrent ? "✓" : "󰕾"
                                            color: isCurrent ? Colors.color(4) : Colors.color(7)
                                            font.pixelSize: 10
                                        }
                                        Text {
                                            text: modelData.description || modelData.name || "Output"
                                            color: isCurrent ? Colors.foreground : Colors.color(7)
                                            font.family: Appearance.fontFamily
                                            font.pixelSize: 10
                                            font.bold: isCurrent
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: Pipewire.preferredDefaultAudioSink = modelData
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Input / Microphone Section
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: inputSection.implicitHeight + 28
                radius: Appearance.radiusLarge
                color: Colors.surfaceSubtle
                border.width: 1
                border.color: Colors.outline

                ColumnLayout {
                    id: inputSection
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "󰍬"; color: Colors.color(2); font.family: Appearance.iconFont; font.pixelSize: 16 }
                        Text {
                            text: "Input Device"
                            color: Colors.foreground
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSize
                            font.bold: true
                        }
                        Text {
                            Layout.fillWidth: true
                            text: root.source?.description || root.source?.name || "Microphone"
                            color: Colors.color(7)
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSizeSmall
                            elide: Text.ElideRight
                        }
                        Text {
                            text: `${Math.round((root.source?.audio?.volume ?? 0) * 100)}%`
                            color: Colors.foreground
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSizeSmall
                            font.bold: true
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        GlassSlider {
                            Layout.fillWidth: true
                            icon: root.source?.audio?.muted ? "󰍭" : "󰍬"
                            value: root.source?.audio?.volume ?? 0
                            onMoved: val => { if (root.source?.audio) root.source.audio.volume = val }
                        }

                        GlassButton {
                            icon: root.source?.audio?.muted ? "󰍭" : "󰍬"
                            text: root.source?.audio?.muted ? "Unmute" : "Mute"
                            accent: root.source?.audio?.muted
                            onClicked: if (root.source?.audio) root.source.audio.muted = !root.source.audio.muted
                        }
                    }
                }
            }

            // Application Volume Streams (Per-App Audio)
            Rectangle {
                Layout.fillWidth: true
                visible: root.streams.length > 0
                implicitHeight: appStreamsSection.implicitHeight + 28
                radius: Appearance.radiusLarge
                color: Colors.surfaceSubtle
                border.width: 1
                border.color: Colors.outline

                ColumnLayout {
                    id: appStreamsSection
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "󰝚"; color: Colors.color(6); font.family: Appearance.iconFont; font.pixelSize: 15 }
                        Text {
                            text: "Application Volumes"
                            color: Colors.foreground
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSize
                            font.bold: true
                        }
                        Text {
                            text: `${root.streams.length} active`
                            color: Colors.color(7)
                            font.family: Appearance.fontFamily
                            font.pixelSize: 10
                        }
                    }

                    Repeater {
                        model: root.streams
                        delegate: ColumnLayout {
                            required property var modelData
                            Layout.fillWidth: true
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: modelData.properties["application.name"] || modelData.description || modelData.name || "App"
                                    color: Colors.foreground
                                    font.family: Appearance.fontFamily
                                    font.pixelSize: Appearance.fontSizeSmall
                                    font.bold: true
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                                Text {
                                    text: `${Math.round((modelData.audio?.volume ?? 0) * 100)}%`
                                    color: Colors.color(7)
                                    font.family: Appearance.fontFamily
                                    font.pixelSize: 10
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                GlassSlider {
                                    Layout.fillWidth: true
                                    icon: modelData.audio?.muted ? "󰝟" : "󰕾"
                                    value: modelData.audio?.volume ?? 0
                                    onMoved: val => { if (modelData.audio) modelData.audio.volume = val }
                                }

                                GlassButton {
                                    icon: modelData.audio?.muted ? "󰝟" : "󰕾"
                                    text: modelData.audio?.muted ? "Unmute" : "Mute"
                                    accent: modelData.audio?.muted
                                    onClicked: if (modelData.audio) modelData.audio.muted = !modelData.audio.muted
                                }
                            }
                        }
                    }
                }
            }

            // Advanced Audio Launcher (pavucontrol)
            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                GlassButton {
                    icon: "󰒓"
                    text: "Advanced Mixer (pavucontrol)"
                    onClicked: Quickshell.execDetached(["pavucontrol"])
                }
            }
        }
    }
}
