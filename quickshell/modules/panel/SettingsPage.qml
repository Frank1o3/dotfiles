import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.config
import qs.config.components
import qs.services

Item {
    id: root
    signal navigate(string page)

    ScrollView {
        id: settingsScroll
        anchors.fill: parent
        clip: true
        contentWidth: availableWidth

        ColumnLayout {
            width: settingsScroll.availableWidth
            spacing: 12

    // Behavior Card
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 600
        radius: Appearance.radiusLarge
        color: Colors.surfaceSubtle
        border.width: 1
        border.color: Colors.outline

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

            Text {
                text: "Bar layout"
                color: Colors.textMuted
                font.family: Appearance.fontFamily
                font.pixelSize: Appearance.fontSizeSmall
            }
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 8
                rowSpacing: 6
                Repeater {
                    model: [
                        { key: "physical", label: "Physical" },
                        { key: "physical-autohide", label: "Physical · auto-hide" },
                        { key: "widget", label: "Widget" },
                        { key: "widget-autohide", label: "Widget · auto-hide" }
                    ]
                    delegate: GlassButton {
                        required property var modelData
                        Layout.fillWidth: true
                        text: modelData.label
                        accent: UserSettings.barMode === modelData.key
                        onClicked: UserSettings.barMode = modelData.key
                    }
                }
            }

            Text {
                text: "Launcher menu"
                color: Colors.textMuted
                font.family: Appearance.fontFamily
                font.pixelSize: Appearance.fontSizeSmall
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                GlassButton {
                    Layout.fillWidth: true
                    text: "Floating widget"
                    accent: UserSettings.launcherMode === "widget"
                    onClicked: UserSettings.launcherMode = "widget"
                }
                GlassButton {
                    Layout.fillWidth: true
                    text: "Physical side panel"
                    accent: UserSettings.launcherMode === "physical"
                    onClicked: UserSettings.launcherMode = "physical"
                }
            }
            Text {
                Layout.fillWidth: true
                text: UserSettings.launcherMode === "physical"
                    ? "The launcher opens as a full-height panel and reserves space while open."
                    : "The launcher opens as a centered floating panel."
                color: Colors.textDim
                font.family: Appearance.fontFamily
                font.pixelSize: Appearance.fontSizeSmall
                wrapMode: Text.Wrap
            }

            Repeater {
                model: [
                    { key: "bar", label: "Bar" },
                    { key: "clock", label: "Clock" },
                    { key: "stats", label: "System stats" },
                    { key: "launcher", label: "Launcher dock" },
                    { key: "appLauncher", label: "Launcher menu" }
                ]
                delegate: RowLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    Text {
                        text: modelData.label
                        color: Colors.textMuted
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSizeSmall
                        Layout.fillWidth: true
                    }
                    GlassButton {
                        text: UserSettings.layout(modelData.key, { layer: "top" }).layer === "under" ? "Below windows" : "Above windows"
                        onClicked: {
                            const state = UserSettings.layout(modelData.key, { scale: 1, layer: "top" });
                            state.layer = state.layer === "under" ? "top" : "under";
                            UserSettings.setLayout(modelData.key, state);
                        }
                    }
                }
            }

            GlassButton {
                Layout.fillWidth: true
                text: UserSettings.layoutEditMode ? "Finish arranging and resizing" : "Arrange and resize shell elements"
                accent: UserSettings.layoutEditMode
                onClicked: UserSettings.layoutEditMode = !UserSettings.layoutEditMode
            }
        }
    }

    // Desktop Settings Grid
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 250
        radius: Appearance.radiusLarge
        color: Colors.surfaceSubtle
        border.width: 1
        border.color: Colors.outline

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: 10
            Text { text: "Desktop Settings & Controls"; color: Colors.foreground; font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSize + 2; font.bold: true }
            Text { text: "Open system configuration tools or shell utilities."; color: Colors.textMuted; font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSizeSmall }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 8
                rowSpacing: 8

                GlassButton {
                    Layout.fillWidth: true
                    icon: "󰤨"
                    text: "Network connections"
                    onClicked: Quickshell.execDetached(["nm-connection-editor"])
                }
                GlassButton {
                    Layout.fillWidth: true
                    icon: "󰍹"
                    text: "Appearance settings"
                    onClicked: Quickshell.execDetached(["qt6ct"])
                }
                GlassButton {
                    Layout.fillWidth: true
                    icon: "󰂯"
                    text: "Bluetooth devices"
                    onClicked: root.navigate("bluetooth")
                }
                GlassButton {
                    Layout.fillWidth: true
                    icon: "󰸉"
                    text: "Choose wallpaper"
                    onClicked: Quickshell.execDetached(["qs", "ipc", "call", "wallpaper", "toggle"])
                }
                GlassButton {
                    Layout.fillWidth: true
                    icon: "󰌌"
                    text: "Keyboard shortcuts"
                    onClicked: Quickshell.execDetached(["qs", "ipc", "call", "cheatsheet", "toggle"])
                }
                GlassButton {
                    Layout.fillWidth: true
                    icon: "󰌾"
                    text: "Lock session"
                    onClicked: Quickshell.execDetached(["qs", "ipc", "call", "lockscreen", "lock"])
                }
            }
        }
    }
        }
    }
}
