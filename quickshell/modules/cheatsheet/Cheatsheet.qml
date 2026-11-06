import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import qs.config
import qs.config.components

Scope {
    id: root

    property bool open: false
    property bool mapped: false
    property string query: ""

    onMappedChanged: OverlayState.cheatsheetMapped = mapped

    readonly property var allSections: [
        { name: "Launch and search", binds: [
            { keys: ["Super", "A / D / Space"], desc: "Open application launcher" },
            { keys: ["Super", "Q / Enter"], desc: "Open terminal" },
            { keys: ["Super", "E"], desc: "Open files" },
            { keys: ["Super", "I"], desc: "Open IDE" },
            { keys: ["Super", "B"], desc: "Open browser" },
            { keys: ["Super", "G"], desc: "Open games" },
            { keys: ["Super", "M"], desc: "Open emoji picker" },
            { keys: ["Super", "/"], desc: "Open this cheatsheet" }
        ] },
        { name: "Windows", binds: [
            { keys: ["Super", "Arrows"], desc: "Focus a neighboring window" },
            { keys: ["Super", "H / K / L"], desc: "Focus left / up / right" },
            { keys: ["Super", "J"], desc: "Toggle split direction" },
            { keys: ["Super", "Shift", "H / J / K / L"], desc: "Move window left / down / up / right" },
            { keys: ["Super", "Shift", "Q"], desc: "Close active window" },
            { keys: ["Super", "F"], desc: "Toggle fullscreen" },
            { keys: ["Super", "Shift", "F"], desc: "Toggle floating" },
            { keys: ["Super", "P"], desc: "Toggle pseudo-tile" }
        ] },
        { name: "Workspaces", binds: [
            { keys: ["Super", "0–9"], desc: "Switch to workspace" },
            { keys: ["Super", "Shift", "0–9"], desc: "Move window to workspace" },
            { keys: ["Super", "S"], desc: "Toggle scratch workspace" },
            { keys: ["Super", "Shift", "S"], desc: "Send window to scratch workspace" },
            { keys: ["Super", "Wheel"], desc: "Switch workspace" }
        ] },
        { name: "Desktop and session", binds: [
            { keys: ["Super", "W"], desc: "Choose wallpaper" },
            { keys: ["Super", "N"], desc: "Toggle notifications" },
            { keys: ["Super", "Shift", "E"], desc: "Open power menu" },
            { keys: ["Arrows / 1–6"], desc: "Choose a power action; Enter runs it" },
            { keys: ["Super", "Shift", "R"], desc: "Reload Hyprland" },
            { keys: ["Super", "Ctrl", "L"], desc: "Lock session" },
            { keys: ["Print"], desc: "Copy selected area screenshot" },
            { keys: ["Super", "Print"], desc: "Copy active window screenshot" }
        ] },
        { name: "Media and hardware", binds: [
            { keys: ["Volume keys"], desc: "Adjust or mute audio" },
            { keys: ["Scroll Lock"], desc: "Toggle audio output" },
            { keys: ["Brightness keys"], desc: "Adjust screen brightness" },
            { keys: ["Media keys"], desc: "Control playback" },
            { keys: ["Super", "Home / End"], desc: "Previous / next track" },
            { keys: ["Super", "PgUp / PgDn"], desc: "Play / stop playback" },
            { keys: ["Super", "Mouse 1 / 2"], desc: "Move / resize window" }
        ] }
    ]

    readonly property var sections: {
        const q = query.trim().toLowerCase();
        if (!q)
            return allSections;
        return allSections.map(section => ({
            name: section.name,
            binds: section.binds.filter(bind => (bind.keys.join(" ") + " " + bind.desc).toLowerCase().includes(q))
        })).filter(section => section.binds.length > 0);
    }

    function show() {
        query = "";
        mapped = true;
        open = true;
        Qt.callLater(() => search.forceActiveFocus());
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
        target: "cheatsheet"
        function toggle(): void { root.toggle(); }
        function open(): void { root.show(); }
        function close(): void { root.hide(); }
    }

    PanelWindow {
        id: win
        visible: root.mapped
        color: "transparent"
        exclusiveZone: 0
        WlrLayershell.namespace: "quickshell:cheatsheet"
        anchors { top: true; bottom: true; left: true; right: true }

        HyprlandFocusGrab {
            windows: [win]
            active: root.open
            onCleared: root.hide()
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.58)
            opacity: root.open ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: Appearance.animFast } }
        }

        MouseArea {
            anchors.fill: parent
            focus: root.open
            onClicked: root.hide()
            Keys.onEscapePressed: root.hide()

            GlassCard {
                id: card
                anchors.centerIn: parent
                width: Math.min(1120, parent.width - 48)
                height: Math.min(820, parent.height - 56)
                cardRadius: Appearance.radiusLarge
                surfaceOpacity: Appearance.panelOpacity
                shadowRadius: Appearance.shadowRadiusLarge
                shadowOffset: Appearance.shadowOffsetLarge
                borderColor: Colors.outlineStrong
                opacity: root.open ? 1 : 0
                scale: root.open ? 1 : 0.97
                Behavior on opacity { NumberAnimation { duration: Appearance.animNormal; easing.type: Easing.OutCubic } }
                Behavior on scale { NumberAnimation { duration: Appearance.animNormal; easing.type: Easing.OutCubic } }

                MouseArea { anchors.fill: parent }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 16

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 14
                        ColumnLayout {
                            spacing: 2
                            Text { text: "Keyboard shortcuts"; color: Colors.foreground; font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSizeLarge + 5; font.weight: Font.Bold }
                            Text { text: "A quick guide to the keys used by this desktop"; color: Colors.color(7); font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSizeSmall }
                        }
                        Item { Layout.fillWidth: true }
                        Rectangle {
                            Layout.preferredWidth: 300
                            Layout.preferredHeight: 38
                            radius: 12
                            color: Qt.rgba(1, 1, 1, 0.07)
                            border.width: 1
                            border.color: search.activeFocus ? Colors.color(4) : Qt.rgba(1, 1, 1, 0.12)
                            TextInput {
                                id: search
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                verticalAlignment: TextInput.AlignVCenter
                                color: Colors.foreground
                                font.family: Appearance.fontFamily
                                font.pixelSize: Appearance.fontSize
                                onTextChanged: root.query = text
                                Keys.onEscapePressed: root.hide()
                            }
                            Text {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                verticalAlignment: Text.AlignVCenter
                                visible: !search.text && !search.activeFocus
                                text: "Filter shortcuts..."
                                color: Colors.textDim
                                font.family: Appearance.fontFamily
                                font.pixelSize: Appearance.fontSize
                            }
                        }
                        GlassButton { text: "Close"; onClicked: root.hide() }
                    }

                    Flickable {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        contentWidth: width
                        contentHeight: cards.implicitHeight
                        clip: true

                        GridLayout {
                            id: cards
                            width: parent.width
                            columns: width >= 820 ? 2 : 1
                            columnSpacing: 14
                            rowSpacing: 14

                            Repeater {
                                model: root.sections
                                Rectangle {
                                    id: sectionCard
                                    required property var modelData
                                    required property int index
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: sectionContent.implicitHeight + 26
                                    radius: Appearance.radiusLarge
                                    color: Qt.rgba(1, 1, 1, 0.035)
                                    border.width: 1
                                    border.color: Qt.rgba(Colors.color(sectionCard.index * 2).r, Colors.color(sectionCard.index * 2).g, Colors.color(sectionCard.index * 2).b, 0.34)
                                    opacity: 0
                                    Component.onCompleted: intro.start()
                                    SequentialAnimation {
                                        id: intro
                                        PauseAnimation { duration: Appearance.animFast > 0 ? sectionCard.index * 24 : 0 }
                                        NumberAnimation { target: sectionCard; property: "opacity"; to: 1; duration: Appearance.animNormal; easing.type: Easing.OutCubic }
                                    }

                                    ColumnLayout {
                                        id: sectionContent
                                        anchors.fill: parent
                                        anchors.margins: 14
                                        spacing: 8
                                        Text {
                                            text: sectionCard.modelData.name
                                            color: Colors.color(sectionCard.index * 2)
                                            font.family: Appearance.fontFamily
                                            font.pixelSize: Appearance.fontSize + 1
                                            font.bold: true
                                        }
                                        Repeater {
                                            model: sectionCard.modelData.binds
                                            RowLayout {
                                                id: bindRow
                                                required property var modelData
                                                Layout.fillWidth: true
                                                spacing: 8
                                                Flow {
                                                    Layout.preferredWidth: 190
                                                    spacing: 4
                                                    Repeater {
                                                        model: bindRow.modelData.keys
                                                        Rectangle {
                                                            required property string modelData
                                                            implicitWidth: keyText.implicitWidth + 12
                                                            implicitHeight: 23
                                                            radius: 7
                                                            color: Qt.rgba(1, 1, 1, 0.08)
                                                            border.width: 1
                                                            border.color: Qt.rgba(1, 1, 1, 0.12)
                                                            Text {
                                                                id: keyText
                                                                anchors.centerIn: parent
                                                                text: modelData
                                                                color: Colors.foreground
                                                                font.family: Appearance.monoFont
                                                                font.pixelSize: 10
                                                            }
                                                        }
                                                    }
                                                }
                                                Text {
                                                    Layout.fillWidth: true
                                                    text: bindRow.modelData.desc
                                                    color: Colors.textMuted
                                                    font.family: Appearance.fontFamily
                                                    font.pixelSize: Appearance.fontSizeSmall
                                                    wrapMode: Text.Wrap
                                                    horizontalAlignment: Text.AlignRight
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
