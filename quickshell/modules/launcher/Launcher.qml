import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.config

Scope {
    id: root

    property bool shown: false
    property var apps: []

    function open() {
        appProc.running = true;
        shown = true;
    }

    function close() {
        shown = false;
        searchField.text = "";
        listView.currentIndex = 0;
    }

    function toggle() {
        shown ? close() : open();
    }

    function launch(app) {
        if (!app)
            return;
        Quickshell.execDetached(["sh", "-c", app.exec]);
        close();
    }

    // qs ipc call launcher toggle|open|close
    IpcHandler {
        target: "launcher"
        function toggle(): void {
            root.toggle();
        }
        function open(): void {
            root.open();
        }
        function close(): void {
            root.close();
        }
    }

    Process {
        id: appProc
        command: ["python3", `${Quickshell.env("HOME")}/.config/quickshell/scripts/list-apps.py`]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.apps = JSON.parse(this.text);
                } catch (e) {
                    root.apps = [];
                }
            }
        }
    }

    PanelWindow {
        id: win
        visible: root.shown
        color: "transparent"
        exclusiveZone: 0

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        HyprlandFocusGrab {
            windows: [win]
            active: root.shown
            onCleared: root.close()
        }

        onVisibleChanged: if (visible)
            searchField.forceActiveFocus()

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()

            Rectangle {
                id: card
                anchors.centerIn: parent
                width: 480
                height: 440
                radius: Appearance.radius
                color: Colors.background
                opacity: 0.97
                border.width: 1
                border.color: Colors.color(1)

                // eat clicks so interacting with the card doesn't close it
                MouseArea {
                    anchors.fill: parent
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 12

                    TextField {
                        id: searchField
                        Layout.fillWidth: true
                        placeholderText: "Search apps..."
                        color: Colors.foreground
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSize + 2
                        font.weight: Font.Bold

                        background: Rectangle {
                            radius: 10
                            color: Qt.rgba(1, 1, 1, 0.06)
                            border.width: 1
                            border.color: Colors.color(8)
                        }

                        Keys.onDownPressed: listView.incrementCurrentIndex()
                        Keys.onUpPressed: listView.decrementCurrentIndex()
                        Keys.onEscapePressed: root.close()
                        onAccepted: root.launch(listView.model[listView.currentIndex])
                        onTextChanged: listView.currentIndex = 0
                    }

                    ListView {
                        id: listView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        currentIndex: 0
                        highlightMoveDuration: 100

                        model: {
                            const q = searchField.text.toLowerCase();
                            if (!q)
                                return root.apps;
                            return root.apps.filter(a => a.name.toLowerCase().includes(q));
                        }

                        delegate: Rectangle {
                            width: listView.width
                            height: 44
                            radius: 8
                            color: ListView.isCurrentItem ? Colors.color(4) : "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 12

                                Image {
                                    Layout.preferredWidth: 28
                                    Layout.preferredHeight: 28
                                    sourceSize.width: 28
                                    sourceSize.height: 28
                                    fillMode: Image.PreserveAspectFit
                                    asynchronous: true
                                    source: {
                                        if (!modelData.icon)
                                            return "";
                                        return modelData.icon.startsWith("/") ? "file://" + modelData.icon : Quickshell.iconPath(modelData.icon, "application-x-executable");
                                    }
                                }

                                Text {
                                    text: modelData.name
                                    color: ListView.isCurrentItem ? Colors.background : Colors.foreground
                                    font.family: Appearance.fontFamily
                                    font.pixelSize: Appearance.fontSize + 1
                                    font.weight: Font.Bold
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: listView.currentIndex = index
                                onClicked: root.launch(modelData)
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: listView.count === 0
                            text: "No matches"
                            color: Colors.color(8)
                            font.family: Appearance.fontFamily
                            font.weight: Font.Bold
                        }
                    }
                }
            }
        }
    }
}
