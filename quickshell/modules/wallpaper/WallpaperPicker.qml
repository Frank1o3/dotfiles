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
    property string viewMode: "shelf"

    readonly property var filteredWallpapers: {
        if (!searchQuery.trim()) return wallpapers;
        const q = searchQuery.toLowerCase().trim();
        return wallpapers.filter(w => (w.name || "").toLowerCase().includes(q));
    }

    function show() {
        root.searchQuery = "";
        searchInput.text = "";
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
                    const selected = root.wallpapers.findIndex(w => w.path === Colors.wallpaper);
                    Qt.callLater(() => carousel.currentIndex = selected >= 0 ? selected : 0);
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
                width: Math.min(parent.width * 0.78, 900)
                height: Math.min(parent.height * 0.76, 600)
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

                        RowLayout {
                            spacing: 3
                            Rectangle {
                                Layout.preferredWidth: 48
                                Layout.preferredHeight: 30
                                radius: 9
                                color: root.viewMode === "grid" ? Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.25) : Qt.rgba(1, 1, 1, 0.045)
                                Text { anchors.centerIn: parent; text: "Grid"; color: Colors.foreground; font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSizeSmall }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.viewMode = "grid" }
                            }
                            Rectangle {
                                Layout.preferredWidth: 52
                                Layout.preferredHeight: 30
                                radius: 9
                                color: root.viewMode === "shelf" ? Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.25) : Qt.rgba(1, 1, 1, 0.045)
                                Text { anchors.centerIn: parent; text: "Shelf"; color: Colors.foreground; font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSizeSmall }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.viewMode = "shelf" }
                            }
                        }

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

                    // Perspective coverflow, centered on the active item.
                    PathView {
                        id: carousel
                        visible: root.viewMode === "shelf"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        focus: true
                        pathItemCount: 5
                        preferredHighlightBegin: 0.5
                        preferredHighlightEnd: 0.5
                        highlightRangeMode: PathView.StrictlyEnforceRange
                        highlightMoveDuration: Appearance.animNormal
                        dragMargin: width * 0.35
                        model: root.filteredWallpapers
                        onCountChanged: if (count > 0 && currentIndex < 0) currentIndex = 0
                        Keys.onLeftPressed: decrementCurrentIndex()
                        Keys.onRightPressed: incrementCurrentIndex()
                        Keys.onReturnPressed: if (currentItem) root.apply(currentItem.modelData.path)
                        Keys.onEnterPressed: if (currentItem) root.apply(currentItem.modelData.path)

                        path: Path {
                            startX: 0
                            startY: carousel.height * 0.62
                            PathAttribute { name: "coverScale"; value: 0.62 }
                            PathAttribute { name: "coverTilt"; value: 58 }
                            PathAttribute { name: "coverOpacity"; value: 0.52 }
                            PathQuad { x: carousel.width / 2; y: carousel.height * 0.40; controlX: carousel.width * 0.22; controlY: carousel.height * 0.39 }
                            PathAttribute { name: "coverScale"; value: 1.0 }
                            PathAttribute { name: "coverTilt"; value: 0 }
                            PathAttribute { name: "coverOpacity"; value: 1.0 }
                            PathQuad { x: carousel.width; y: carousel.height * 0.62; controlX: carousel.width * 0.78; controlY: carousel.height * 0.39 }
                            PathAttribute { name: "coverScale"; value: 0.62 }
                            PathAttribute { name: "coverTilt"; value: -58 }
                            PathAttribute { name: "coverOpacity"; value: 0.52 }
                        }

                        delegate: Item {
                            id: cell
                            required property var modelData
                            width: Math.min(420, carousel.width * 0.55)
                            height: Math.min(300, carousel.height * 0.84)
                            required property int index
                            z: Math.round((PathView.coverScale ?? 1) * 100)
                            scale: PathView.coverScale ?? 1
                            opacity: PathView.coverOpacity ?? 1
                            transform: Rotation {
                                origin.x: cell.width / 2
                                origin.y: cell.height / 2
                                axis.x: 0
                                axis.y: 1
                                axis.z: 0
                                angle: PathView.coverTilt ?? 0
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: 18
                                color: Qt.rgba(0.04, 0.05, 0.08, 0.40)
                                clip: true
                                border.width: PathView.isCurrentItem ? 2 : 1
                                border.color: PathView.isCurrentItem ? Colors.color(4) : Qt.rgba(1, 1, 1, 0.16)

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

                            }

                            MouseArea {
                                id: hoverArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: carousel.currentIndex = index
                                onClicked: {
                                    if (cell.PathView.isCurrentItem) root.apply(cell.modelData.path);
                                    else carousel.currentIndex = index;
                                }
                            }
                        }
                    }

                    GridView {
                        id: wallpaperGrid
                        visible: root.viewMode === "grid"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        cellWidth: width / 3
                        cellHeight: Math.max(128, Math.min(184, height / 2))
                        model: root.filteredWallpapers

                        delegate: Item {
                            id: gridCell
                            required property var modelData
                            required property int index
                            width: wallpaperGrid.cellWidth
                            height: wallpaperGrid.cellHeight

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 5
                                radius: 12
                                color: Qt.rgba(0.04, 0.05, 0.08, 0.5)
                                clip: true
                                border.width: carousel.currentIndex === gridCell.index ? 2 : 1
                                border.color: carousel.currentIndex === gridCell.index ? Colors.color(4) : Qt.rgba(1, 1, 1, 0.13)

                                Image {
                                    anchors.fill: parent
                                    source: "file://" + gridCell.modelData.path
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    smooth: true
                                }

                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    height: 30
                                    color: Qt.rgba(0.03, 0.04, 0.07, 0.78)
                                    Text {
                                        anchors.fill: parent
                                        anchors.leftMargin: 9
                                        anchors.rightMargin: 7
                                        verticalAlignment: Text.AlignVCenter
                                        text: gridCell.modelData.name
                                        color: Colors.foreground
                                        font.family: Appearance.fontFamily
                                        font.pixelSize: Appearance.fontSizeSmall
                                        elide: Text.ElideMiddle
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: carousel.currentIndex = gridCell.index
                                    onClicked: { carousel.currentIndex = gridCell.index; root.apply(gridCell.modelData.path) }
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            Layout.fillWidth: true
                            text: carousel.currentItem ? carousel.currentItem.modelData.name : "No wallpapers found"
                            color: Colors.foreground
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSize
                            font.bold: true
                            elide: Text.ElideMiddle
                        }
                        Text { text: root.viewMode === "shelf" ? "←  →  browse     Enter  apply" : "Select a thumbnail to apply"; color: Colors.color(7); font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSizeSmall }
                    }
                }
            }
        }
    }
}
