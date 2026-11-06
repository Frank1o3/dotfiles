import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services

PanelWindow {
    id: win
    required property var screenData
    required property string widgetKey
    required property real defaultX
    required property real defaultY
    screen: screenData
    visible: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: `quickshell:widget-${widgetKey}`
    WlrLayershell.layer: UserSettings.layout(widgetKey, { layer: "top" }).layer === "under" ? WlrLayer.Bottom : WlrLayer.Top
    anchors { top: true; right: true; bottom: true; left: true }

    mask: Region {
        item: UserSettings.layoutEditMode
            ? widget
            : (win.widgetKey === "launcher" ? launcherLoader.item : null)
        Region { item: UserSettings.layoutEditMode ? editHint : null }
    }

    Item {
        id: widget
        property var savedPosition: UserSettings.position(win.widgetKey, win.defaultX, win.defaultY)
        x: savedPosition.x * Math.max(0, win.width - width)
        y: savedPosition.y * Math.max(0, win.height - height)
        width: content.implicitWidth + (UserSettings.layoutEditMode ? 18 : 0)
        height: content.implicitHeight + (UserSettings.layoutEditMode ? 18 : 0)
        scale: UserSettings.layout(win.widgetKey, { scale: 1 }).scale
        transformOrigin: Item.TopLeft

        Rectangle {
            anchors.fill: parent
            radius: 12
            color: UserSettings.layoutEditMode ? Qt.rgba(0.08, 0.07, 0.14, 0.76) : "transparent"
            border.width: UserSettings.layoutEditMode ? 1 : 0
            border.color: Colors.accentOutline
        }

        Item {
            anchors.centerIn: parent
            width: content.implicitWidth
            height: content.implicitHeight
            ColumnLayout {
                id: content
                spacing: 8
                Loader { active: win.widgetKey === "clock"; sourceComponent: clockWidget }
                Loader { active: win.widgetKey === "stats"; sourceComponent: statsWidget }
                Loader { id: launcherLoader; active: win.widgetKey === "launcher"; sourceComponent: launcherWidget }
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: UserSettings.layoutEditMode
            visible: UserSettings.layoutEditMode
            cursorShape: UserSettings.layoutEditMode ? Qt.SizeAllCursor : Qt.ArrowCursor
            drag.target: widget
            onReleased: UserSettings.savePosition(win.widgetKey,
                widget.x / Math.max(1, win.width - widget.width),
                widget.y / Math.max(1, win.height - widget.height))
        }

        Rectangle {
            z: 2
            visible: UserSettings.layoutEditMode
            width: 18; height: 18; radius: 5
            anchors.right: parent.right; anchors.bottom: parent.bottom
            color: Colors.accentColor
            Text { anchors.centerIn: parent; text: "↘"; color: Colors.background; font.pixelSize: 12 }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.SizeFDiagCursor
                property real initialScale: 1
                property real initialX: 0
                property real initialY: 0
                onPressed: function(mouse) {
                    initialScale = UserSettings.layout(win.widgetKey, { scale: 1 }).scale;
                    initialX = mouse.x; initialY = mouse.y;
                }
                onPositionChanged: function(mouse) {
                    if (pressed) {
                        const state = UserSettings.layout(win.widgetKey, { scale: 1, layer: "top" });
                        state.scale = Math.max(0.65, Math.min(2, initialScale + ((mouse.x - initialX) + (mouse.y - initialY)) / 160));
                        UserSettings.setLayout(win.widgetKey, state);
                    }
                }
            }
        }
    }

    Text {
        id: editHint
        visible: UserSettings.layoutEditMode && win.widgetKey === "clock"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 14
        text: "EDIT LAYOUT  ·  drag to move  ·  use corner to resize"
        color: Colors.foreground
        font.family: Appearance.monoFont
        font.pixelSize: Appearance.fontSizeSmall
    }

    Component {
        id: clockWidget
        Column {
            spacing: 0
            Text {
                id: clockText
                text: Qt.formatTime(new Date(), "hh:mm")
                color: "#e9e8f3"
                font.family: Appearance.fontFamily
                font.pixelSize: 52
                font.weight: Font.Light
                Timer {
                    interval: 1000; running: true; repeat: true
                    onTriggered: clockText.text = Qt.formatTime(new Date(), "hh:mm")
                }
            }
            Text {
                id: dateText
                text: Qt.formatDate(new Date(), "ddd, MMM dd").toUpperCase()
                color: "#c4c2d1"
                font.family: Appearance.monoFont
                font.pixelSize: 11
                font.letterSpacing: 4
                Timer {
                    interval: 60000; running: true; repeat: true
                    onTriggered: dateText.text = Qt.formatDate(new Date(), "ddd, MMM dd").toUpperCase()
                }
            }
        }
    }

    Component {
        id: statsWidget
        Column {
            spacing: 12
            Repeater {
                model: [
                    { label: "CPU", value: `${SysMonitor.cpuUsage}%`, icon: "󰻠" },
                    { label: "RAM", value: `${SysMonitor.memoryUsage}%`, icon: "󰍛" },
                    { label: "DISK", value: `${SysMonitor.diskUsage}%`, icon: "󰋊" }
                ]
                delegate: Row {
                    required property var modelData
                    spacing: 12
                    Text { text: modelData.icon; color: "#deddeb"; font.family: Appearance.iconFont; font.pixelSize: 20; anchors.verticalCenter: parent.verticalCenter }
                    Column {
                        width: 136
                        spacing: 3
                        Row {
                            width: parent.width
                            Text { text: modelData.label; color: "#e3e1ec"; font.family: Appearance.monoFont; font.pixelSize: 10; font.letterSpacing: 2 }
                            Item { width: parent.width - 100; height: 1 }
                            Text { text: modelData.value; color: "#e3e1ec"; font.family: Appearance.monoFont; font.pixelSize: 10 }
                        }
                        Rectangle {
                            width: parent.width; height: 2; color: "#434352"
                            Rectangle { width: parent.width * Math.min(100, parseInt(modelData.value) || 0) / 100; height: parent.height; color: Colors.accentColor }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: launcherWidget
        Column {
            spacing: 4
            Repeater {
                model: [
                    { icon: "󰣇", command: ["qs", "ipc", "call", "launcher", "toggle"] },
                    { icon: "", command: ["xdg-open", Quickshell.env("HOME")] },
                    { icon: "󰈹", command: ["firefox"] },
                    { icon: "󰆍", command: ["kitty"] },
                    { icon: "󰙯", command: ["discord"] },
                    { icon: "󰓇", command: ["spotify"] }
                ]
                delegate: Text {
                    required property var modelData
                    text: modelData.icon
                    color: mouse.containsMouse ? Colors.accentColor : "#deddeb"
                    font.family: Appearance.iconFont
                    font.pixelSize: 23
                    MouseArea { id: mouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Quickshell.execDetached(modelData.command) }
                }
            }
        }
    }
}
