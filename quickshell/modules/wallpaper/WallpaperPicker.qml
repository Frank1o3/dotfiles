import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
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
    property var wallpaperColors: []
    property string searchQuery: ""
    property string viewMode: "shelf"

    onMappedChanged: OverlayState.wallpaperPickerMapped = mapped

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
        interval: Math.max(1, Appearance.animNormal)
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
        if (!path)
            return;
        applyProc.path = path;
        applyProc.running = true;
        root.hide();
    }

    function selectRandom() {
        if (filteredWallpapers.length < 2)
            return;

        let next = Math.floor(Math.random() * filteredWallpapers.length);
        if (next === carousel.currentIndex)
            next = (next + 1 + Math.floor(Math.random() * (filteredWallpapers.length - 1))) % filteredWallpapers.length;
        carousel.currentIndex = next;
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

        Image {
            id: wallpaperBackdrop
            anchors.fill: parent
            source: GameMode.active ? "" : carousel.currentItem ? "file://" + carousel.currentItem.modelData.path : (Colors.wallpaper ? "file://" + Colors.wallpaper : "")
            sourceSize.width: 1280
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            visible: false
        }

        MultiEffect {
            anchors.fill: parent
            source: wallpaperBackdrop
            blurEnabled: !GameMode.active
            blur: 1
            blurMax: 64
            brightness: -0.28
            saturation: 0.35
            opacity: root.open ? 1 : 0
            visible: !GameMode.active
            Behavior on opacity { NumberAnimation { duration: Appearance.animNormal } }
        }

        Rectangle {
            anchors.fill: parent
            color: "#99070910"
            opacity: root.open ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: Appearance.animFast } }
        }

        // Clicking the dimmed area closes the gallery; the gallery itself
        // consumes pointer input through its child controls.
        MouseArea {
            anchors.fill: parent
            focus: root.open
            onClicked: root.hide()
            Keys.onEscapePressed: root.hide()
            Keys.onLeftPressed: if (root.viewMode === "shelf") carousel.decrementCurrentIndex()
            Keys.onRightPressed: if (root.viewMode === "shelf") carousel.incrementCurrentIndex()
            Keys.onReturnPressed: if (carousel.currentItem) root.apply(carousel.currentItem.modelData.path)

            Item {
                id: content
                anchors.fill: parent
                anchors.leftMargin: 44
                anchors.rightMargin: 44
                anchors.topMargin: 30
                anchors.bottomMargin: 24
                opacity: root.open ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: Appearance.animFast } }

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 14

                    // Header and gallery controls.
                    RowLayout {
                        id: toolbar
                        Layout.fillWidth: true
                        spacing: 12

                        Text {
                            text: "▣  WALLPAPER GALLERY"
                            color: Colors.foreground
                            font.family: Appearance.fontFamily
                            font.pixelSize: 13
                            font.weight: Font.Bold
                            font.letterSpacing: 0.7
                        }

                        Item { Layout.fillWidth: true }

                        RowLayout {
                            spacing: 4
                            Rectangle {
                                Layout.preferredWidth: 48
                                Layout.preferredHeight: 32
                                radius: 10
                                color: root.viewMode === "grid" ? Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.3) : Qt.rgba(1, 1, 1, 0.07)
                                Text { anchors.centerIn: parent; text: "Grid"; color: Colors.foreground; font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSizeSmall }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.viewMode = "grid" }
                            }
                            Rectangle {
                                Layout.preferredWidth: 52
                                Layout.preferredHeight: 32
                                radius: 10
                                color: root.viewMode === "shelf" ? Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.3) : Qt.rgba(1, 1, 1, 0.07)
                                Text { anchors.centerIn: parent; text: "Shelf"; color: Colors.foreground; font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSizeSmall }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.viewMode = "shelf" }
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 38
                            Layout.preferredHeight: 32
                            radius: 16
                            color: randomMouse.containsMouse ? Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.3) : Qt.rgba(1, 1, 1, 0.07)
                            Text { anchors.centerIn: parent; text: "⤨"; color: Colors.foreground; font.pixelSize: 17 }
                            MouseArea {
                                id: randomMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.selectRandom()
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 250
                            Layout.preferredHeight: 34
                            radius: 17
                            color: Qt.rgba(1, 1, 1, 0.09)
                            border.width: 1
                            border.color: searchInput.activeFocus ? Colors.color(4) : Qt.rgba(1, 1, 1, 0.15)

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 8
                                Text { text: "⌕"; color: Colors.color(7); font.pixelSize: 16 }

                                Item {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    TextInput {
                                        id: searchInput
                                        anchors.fill: parent
                                        verticalAlignment: TextInput.AlignVCenter
                                        font.family: Appearance.fontFamily
                                        font.pixelSize: 12
                                        color: Colors.foreground
                                        clip: true
                                        onTextChanged: root.searchQuery = text
                                        Keys.onReturnPressed: if (carousel.currentItem) root.apply(carousel.currentItem.modelData.path)
                                        Keys.onEnterPressed: if (carousel.currentItem) root.apply(carousel.currentItem.modelData.path)
                                    }
                                    Text {
                                        anchors.fill: parent
                                        verticalAlignment: Text.AlignVCenter
                                        visible: !searchInput.text && !searchInput.activeFocus
                                        text: "Filter wallpapers..."
                                        color: Qt.rgba(1, 1, 1, 0.45)
                                        font.family: Appearance.fontFamily
                                        font.pixelSize: 12
                                    }
                                }
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 34
                            Layout.preferredHeight: 34
                            radius: 17
                            color: closeMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.19) : Qt.rgba(1, 1, 1, 0.08)
                            Text { anchors.centerIn: parent; text: "✕"; color: Colors.foreground; font.pixelSize: 13; font.bold: true }
                            MouseArea {
                                id: closeMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.hide()
                            }
                        }
                    }

                    // Coverflow shelf and the optional thumbnail grid share
                    // one selected index and the same apply action.
                    PathView {
                        id: carousel
                        visible: root.viewMode === "shelf"
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        focus: true
                        pathItemCount: 9
                        preferredHighlightBegin: 0.5
                        preferredHighlightEnd: 0.5
                        highlightRangeMode: PathView.StrictlyEnforceRange
                        highlightMoveDuration: Appearance.animSlow
                        cacheItemCount: 4
                        dragMargin: width * 0.35
                        model: root.filteredWallpapers
                        Keys.onLeftPressed: decrementCurrentIndex()
                        Keys.onRightPressed: incrementCurrentIndex()
                        Keys.onUpPressed: decrementCurrentIndex()
                        Keys.onDownPressed: incrementCurrentIndex()
                        Keys.onReturnPressed: if (currentItem) root.apply(currentItem.modelData.path)
                        Keys.onEnterPressed: if (currentItem) root.apply(currentItem.modelData.path)
                        onCountChanged: {
                            if (count === 0) currentIndex = -1;
                            else if (currentIndex < 0 || currentIndex >= count) currentIndex = 0;
                        }

                        path: Path {
                            startX: 0
                            startY: carousel.height * 0.56
                            PathAttribute { name: "coverScale"; value: 0.68 }
                            PathAttribute { name: "coverTilt"; value: 46 }
                            PathAttribute { name: "coverOpacity"; value: 0.62 }
                            PathQuad { x: carousel.width / 2; y: carousel.height * 0.50; controlX: carousel.width * 0.22; controlY: carousel.height * 0.46 }
                            PathAttribute { name: "coverScale"; value: 1.0 }
                            PathAttribute { name: "coverTilt"; value: 0 }
                            PathAttribute { name: "coverOpacity"; value: 1.0 }
                            PathQuad { x: carousel.width; y: carousel.height * 0.56; controlX: carousel.width * 0.78; controlY: carousel.height * 0.46 }
                            PathAttribute { name: "coverScale"; value: 0.68 }
                            PathAttribute { name: "coverTilt"; value: -46 }
                            PathAttribute { name: "coverOpacity"; value: 0.62 }
                        }

                        delegate: Item {
                            id: cell
                            required property var modelData
                            required property int index
                            width: Math.min(720, carousel.width * 0.44, carousel.height * 0.92 * 16 / 9)
                            height: width * 9 / 16
                            z: Math.round((PathView.coverScale ?? 1) * 100)
                            scale: PathView.coverScale ?? 1
                            opacity: PathView.coverOpacity ?? 1
                            transform: Rotation {
                                origin.x: cell.width / 2
                                origin.y: cell.height / 2
                                axis { x: 0; y: 1; z: 0 }
                                angle: PathView.coverTilt ?? 0
                            }

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: -10
                                radius: 32
                                visible: PathView.isCurrentItem
                                color: Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.35)
                            }

                            ClippingRectangle {
                                anchors.fill: parent
                                radius: 22
                                color: Qt.rgba(0.04, 0.05, 0.08, 0.8)
                                border.width: PathView.isCurrentItem ? 3 : 1
                                border.color: PathView.isCurrentItem ? Colors.color(4) : Qt.rgba(1, 1, 1, 0.16)

                                Image {
                                    id: wallpaperImage
                                    anchors.fill: parent
                                    source: "file://" + cell.modelData.path
                                    sourceSize.width: 900
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    cache: true
                                }

                                Rectangle {
                                    visible: cell.modelData.path === Colors.wallpaper
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    anchors.margins: 12
                                    implicitWidth: currentLabel.implicitWidth + 18
                                    implicitHeight: 25
                                    radius: 13
                                    color: Qt.rgba(0.03, 0.04, 0.07, 0.82)
                                    Text {
                                        id: currentLabel
                                        anchors.centerIn: parent
                                        text: "CURRENT"
                                        color: Colors.foreground
                                        font.family: Appearance.fontFamily
                                        font.pixelSize: 9
                                        font.bold: true
                                        font.letterSpacing: 0.5
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (cell.PathView.isCurrentItem)
                                        root.apply(cell.modelData.path);
                                    else
                                        carousel.currentIndex = cell.index;
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
                        cellWidth: width / 4
                        cellHeight: Math.max(120, Math.min(210, height / 2))
                        model: root.filteredWallpapers

                        delegate: Item {
                            id: gridCell
                            required property var modelData
                            required property int index
                            width: wallpaperGrid.cellWidth
                            height: wallpaperGrid.cellHeight

                            ClippingRectangle {
                                anchors.fill: parent
                                anchors.margins: 5
                                radius: 12
                                color: Qt.rgba(0.04, 0.05, 0.08, 0.65)
                                border.width: carousel.currentIndex === gridCell.index ? 2 : 1
                                border.color: carousel.currentIndex === gridCell.index ? Colors.color(4) : Qt.rgba(1, 1, 1, 0.14)
                                Image {
                                    anchors.fill: parent
                                    source: "file://" + gridCell.modelData.path
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                }
                                Rectangle {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    height: 32
                                    color: Qt.rgba(0.03, 0.04, 0.07, 0.8)
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
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        carousel.currentIndex = gridCell.index;
                                        root.apply(gridCell.modelData.path);
                                    }
                                }
                            }
                        }
                    }

                    // Selected wallpaper name, sampled palette, and footer.
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 108
                        spacing: 7

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: carousel.currentItem ? carousel.currentItem.modelData.name : (root.wallpapers.length ? "No wallpapers match" : "Loading wallpapers…")
                            color: Colors.foreground
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSize + 1
                            font.bold: true
                            elide: Text.ElideMiddle
                        }

                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 6
                            Repeater {
                                model: root.wallpaperColors.slice(0, 8)
                                Rectangle {
                                    required property color modelData
                                    implicitWidth: 28
                                    implicitHeight: 28
                                    radius: 8
                                    color: modelData
                                    border.width: 1
                                    border.color: Qt.rgba(1, 1, 1, 0.35)
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            Text {
                                text: carousel.currentIndex >= 0 ? `${carousel.currentIndex + 1} / ${root.filteredWallpapers.length}` : "Try another search"
                                color: Colors.color(7)
                                font.family: Appearance.monoFont
                                font.pixelSize: 10
                            }
                            Text {
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                                text: root.viewMode === "shelf" ? "← → browse   ·   Enter apply   ·   Esc close" : "Select a thumbnail to apply   ·   Esc close"
                                color: Colors.color(7)
                                font.family: Appearance.fontFamily
                                font.pixelSize: 10
                            }
                            GlassButton {
                                text: "Apply wallpaper  ↵"
                                accent: true
                                enabled: !!carousel.currentItem
                                onClicked: if (carousel.currentItem) root.apply(carousel.currentItem.modelData.path)
                            }
                        }
                    }
                }
            }
        }

        ColorQuantizer {
            id: wallpaperPalette
            source: root.open && carousel.currentItem ? "file://" + carousel.currentItem.modelData.path : ""
            depth: 3
            rescaleSize: 64
            onColorsChanged: root.wallpaperColors = colors
        }
    }
}
