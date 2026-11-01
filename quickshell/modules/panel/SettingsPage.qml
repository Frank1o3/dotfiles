import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.config.components
import qs.services

ColumnLayout {
    id: root
    signal navigate(string page)
    spacing: 12

    // Behavior Card
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 184
        radius: Appearance.radiusLarge
        color: Qt.rgba(1, 1, 1, 0.035)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.08)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 10
            Text { text: "Behavior & Energy"; color: Colors.foreground; font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSize + 2; font.bold: true }
            Text {
                Layout.fillWidth: true
                text: GameMode.active
                    ? "Game Mode is active. Shell transitions, wallpaper blur, shadows, and background sampling are paused."
                    : "Desktop motion and effects are lightweight. Caffeine mode prevents system display sleeping."
                color: Colors.textMuted
                font.family: Appearance.fontFamily
                font.pixelSize: Appearance.fontSizeSmall
                wrapMode: Text.Wrap
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                QuickToggle {
                    Layout.fillWidth: true
                    icon: "󰂛"
                    label: "Do Not Disturb"
                    subLabel: Notifications.dnd ? "Alerts muted" : "Alerts enabled"
                    active: Notifications.dnd
                    onClicked: Notifications.toggleDnd()
                }
                QuickToggle {
                    Layout.fillWidth: true
                    icon: Caffeine.active ? "󰅶" : "󰾪"
                    label: "Caffeine"
                    subLabel: Caffeine.active ? "Screen awake" : "Normal sleep"
                    active: Caffeine.active
                    onClicked: Caffeine.toggle()
                }
                QuickToggle {
                    Layout.fillWidth: true
                    icon: "󰊴"
                    label: "Game Mode"
                    subLabel: GameMode.active ? "Performance" : "Automatic"
                    active: GameMode.active
                    interactive: false
                }
            }
        }
    }

    // Desktop Settings Grid
    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: Appearance.radiusLarge
        color: Qt.rgba(1, 1, 1, 0.035)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.08)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 10
            Text { text: "Desktop Settings & Controls"; color: Colors.foreground; font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSize + 2; font.bold: true }
            Text { text: "Open system configuration tools or shell utilities."; color: Colors.textMuted; font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSizeSmall }

            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 2
                columnSpacing: 8
                rowSpacing: 8

                GlassButton {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    icon: "󰤨"
                    text: "Network connections"
                    onClicked: Quickshell.execDetached(["nm-connection-editor"])
                }
                GlassButton {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    icon: "󰍹"
                    text: "Appearance settings"
                    onClicked: Quickshell.execDetached(["qt6ct"])
                }
                GlassButton {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    icon: "󰂯"
                    text: "Bluetooth devices"
                    onClicked: root.navigate("bluetooth")
                }
                GlassButton {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    icon: "󰸉"
                    text: "Choose wallpaper"
                    onClicked: Quickshell.execDetached(["qs", "ipc", "call", "wallpaper", "toggle"])
                }
                GlassButton {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    icon: "󰌌"
                    text: "Keyboard shortcuts"
                    onClicked: Quickshell.execDetached(["qs", "ipc", "call", "cheatsheet", "toggle"])
                }
                GlassButton {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    icon: "󰌾"
                    text: "Lock session"
                    onClicked: Quickshell.execDetached(["qs", "ipc", "call", "lockscreen", "lock"])
                }
            }
        }
    }
}
