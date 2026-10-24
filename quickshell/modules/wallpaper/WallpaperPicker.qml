import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs.config.components

Scope {
    id: root

    property bool open: false
    property bool mapped: false
    property var wallpapers: []
    property string searchQuery: ""

    readonly property var filteredWallpapers: {
        if (!searchQuery.trim()) return wallpapers;
        const q = searchQuery.toLowerCase().trim();
        return wallpapers.filter(w => (w.name || "").toLowerCase().includes(q));
    }

    function show() {
        listProc.running = true;
        mapped = true;
        open = true;
    }
    function hide() {
        open = false;
        closeTimer.start();
    }
    function toggle() {
        open ? hide() : show();
    }

    Timer {
        id: closeTimer
        interval: 220
        onTriggered: root.mapped = false
    }

    IpcHandler {
        target: "wallpaper"
        function toggle(): void { root.toggle(); }
        function open(): void { root.show(); }
        function close(): void { root.hide(); }
    }

    Process {
        id: listProc
        command: ["python3", `${Quickshell.env("HOME")}/.config/quickshell/scripts/list-wallpapers.py`]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.wallpapers = JSON.parse(this.text);
                } catch (e) {
                    root.wallpapers = [];
                }
            }
        }
    }

    Process {
        id: applyProc
        property string path: ""
        command: ["sh", Quickshell.env("HOME") + "/.config/hypr/scripts/set-wallpaper.sh", path]
    }

    function apply(path) {
        applyProc.path = path;
        applyProc.running = true;
        root.hide();
    }

    PanelWindow {
        id: win
        visible: root.mapped
        color: "transparent"
        exclusiveZone: 0
        WlrLayershell.namespace: "quickshell:wallpaper"

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        HyprlandFocusGrab {
            windows: [win]
            active: root.open
            onCleared: root.hide()
        }

        // Dimmed backdrop click to dismiss
        MouseArea {
            anchors.fill: parent
            onClicked: root.hide()

            GlassCard {
                id: card
                anchors.centerIn: parent
                width: Math.min(parent.width * 0.78, 960)
                height: Math.min(parent.height * 0.80, 680)
                cardRadius: Appearance.radiusLarge
                surfaceOpacity: Appearance.panelOpacity
                shadowRadius: Appearance.shadowRadiusLarge
                shadowOffset: Appearance.shadowOffsetLarge

                opacity: root.open ? 1 : 0
                transformOrigin: Item.Center
                scale: root.open ? 1 : 0.92

                Behavior on scale {
                    NumberAnimation {
                        duration: 260
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.05
                    }
                }
                Behavior on opacity {
                    NumberAnimation { duration: 200 }
                }

                MouseArea {
                    anchors.fill: parent
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 22
                    spacing: 16

                    // Header row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 14

                        Text {
                            text: "󰸉  Wallpaper Gallery"
                            color: Colors.foreground
                            font.family: Appearance.fontFamily
                            font.pixelSize: 18
                            font.weight: Font.Bold
                        }

                        Item { Layout.fillWidth: true }

                        // Search box
                        Rectangle {
                            Layout.preferredWidth: 220
                            Layout.preferredHeight: 34
                            radius: 17
                            color: Qt.rgba(1, 1, 1, 0.08)
                            border.width: 1
                            border.color: searchInput.activeFocus ? Colors.color(4) : Qt.rgba(1, 1, 1, 0.12)

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 8

                                Text {
                                    text: "󰍉"
                                    color: Colors.color(7)
                                    font.family: Appearance.iconFont
                                    font.pixelSize: 13
                                }

                                TextInput {
                                    id: searchInput
                                    Layout.fillWidth: true
                                    font.family: Appearance.fontFamily
                                    font.pixelSize: 12
                                    color: Colors.foreground
                                    clip: true
                                    onTextChanged: root.searchQuery = text

                                    Text {
                                        visible: !searchInput.text && !searchInput.activeFocus
                                        text: "Filter wallpapers..."
                                        color: Qt.rgba(1, 1, 1, 0.40)
                                        font.family: Appearance.fontFamily
                                        font.pixelSize: 12
                                    }
                                }
                            }
                        }

                        // Close button
                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: 16
                            color: closeMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.08)
                            border.width: 1
                            border.color: Qt.rgba(1, 1, 1, 0.14)

                            Text {
                                anchors.centerIn: parent
                                text: "✕"
                                color: Colors.foreground
                                font.family: Appearance.fontFamily
                                font.pixelSize: 13
                                font.bold: true
                            }

                            MouseArea {
                                id: closeMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.hide()
                            }
                        }
                    }

                    // Grid
                    GridView {
                        id: grid
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        cellWidth: 280
                        cellHeight: 180
                        model: root.filteredWallpapers

                        delegate: Item {
                            id: cell
                            required property var modelData
                            width: grid.cellWidth - 14
                            height: grid.cellHeight - 14
                            property bool hovered: hoverArea.containsMouse

                            Rectangle {
                                anchors.fill: parent
                                radius: 14
                                color: "transparent"
                                clip: true
                                border.width: cell.hovered ? 2 : 1
                                border.color: cell.hovered ? Colors.color(4) : Qt.rgba(1, 1, 1, 0.12)
                                scale: cell.hovered ? 1.03 : 1.0

                                Behavior on scale {
                                    NumberAnimation {
                                        duration: Appearance.animFast
                                        easing.type: Easing.OutCubic
                                    }
                                }
                                Behavior on border.color {
                                    ColorAnimation { duration: Appearance.animFast }
                                }

                                Image {
                                    anchors.fill: parent
                                    source: "file://" + cell.modelData.path
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    smooth: true
                                }

                                // Floating frosted glass label pill
                                Rectangle {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: 8
                                    width: Math.min(parent.width - 24, nameText.implicitWidth + 24)
                                    height: 26
                                    radius: 13
                                    color: Qt.rgba(0, 0, 0, 0.55)
                                    border.width: 1
                                    border.color: Qt.rgba(1, 1, 1, 0.18)

                                    Text {
                                        id: nameText
                                        anchors.centerIn: parent
                                        text: cell.modelData.name
                                        color: "#ffffff"
                                        font.family: Appearance.fontFamily
                                        font.pixelSize: 11
                                        font.weight: Font.DemiBold
                                        elide: Text.ElideRight
                                        width: parent.width - 16
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                            }

                            MouseArea {
                                id: hoverArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.apply(cell.modelData.path)
                            }
                        }
                    }
                }
            }
        }
    }
}
