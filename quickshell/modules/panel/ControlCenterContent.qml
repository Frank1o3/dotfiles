import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth
import Quickshell.Networking
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs.config
import qs.config.components
import qs.modules.panel
import qs.services

RowLayout {
    id: root

    spacing: 16
    implicitWidth: 860
    implicitHeight: 520

    property bool panelOpen: false
    property bool brightnessAvailable: false
    property string page: PanelState.targetPage || "home"

    Connections {
        target: PanelState
        function onTargetPageChanged() {
            root.page = PanelState.targetPage;
        }
    }
    onPageChanged: PanelState.targetPage = root.page
    onPanelOpenChanged: if (!panelOpen) PanelState.targetPage = "home"

    readonly property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property string pageTitle: page === "notifications" ? "Notifications"
        : page === "audio" ? "Audio & Media"
        : page === "wifi" ? "Wi-Fi"
        : page === "bluetooth" ? "Bluetooth"
        : page === "system" ? "System Monitor"
        : page === "settings" ? "Settings" : "Overview"

    readonly property var destinations: [
        { key: "home", title: "Home", icon: "󰋜" },
        { key: "notifications", title: "Alerts", icon: "󰂚", badge: Notifications.count },
        { key: "audio", title: "Audio", icon: "󰕾" },
        { key: "wifi", title: "Wi-Fi", icon: "󰖩" },
        { key: "bluetooth", title: "Bluetooth", icon: "󰂯" },
        { key: "system", title: "System", icon: "󰍛" },
        { key: "settings", title: "Settings", icon: "󰒓" }
    ]

    // Persistent navigation rail
    Rectangle {
        id: rail
        Layout.preferredWidth: 104
        Layout.fillHeight: true
        radius: Appearance.radiusLarge
        color: Qt.rgba(0, 0, 0, 0.24)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.07)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 4

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 38
                Layout.preferredHeight: 38
                radius: 14
                color: Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.18)
                Text {
                    anchors.centerIn: parent
                    text: "󰀻"
                    color: Colors.color(4)
                    font.family: Appearance.iconFont
                    font.pixelSize: 20
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                Layout.topMargin: 3
                Layout.bottomMargin: 2
                color: Qt.rgba(1, 1, 1, 0.10)
            }

            Repeater {
                model: root.destinations
                delegate: Item {
                    id: navItem
                    required property var modelData
                    readonly property bool selected: root.page === modelData.key
                    Layout.fillWidth: true
                    Layout.preferredHeight: 54

                    Rectangle {
                        anchors.fill: parent
                        radius: 13
                        color: navItem.selected
                            ? Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.22)
                            : navMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.07) : "transparent"
                        border.width: navItem.selected ? 1 : 0
                        border.color: Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.42)
                        Behavior on color { ColorAnimation { duration: Appearance.animFast } }

                        // Notification count badge
                        Rectangle {
                            visible: !!navItem.modelData.badge && navItem.modelData.badge > 0
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.topMargin: 4
                            anchors.rightMargin: 6
                            width: 14
                            height: 14
                            radius: 7
                            color: Colors.color(1)
                            Text {
                                anchors.centerIn: parent
                                text: (navItem.modelData.badge ?? 0) > 9 ? "9+" : String(navItem.modelData.badge ?? "")
                                color: Colors.background
                                font.pixelSize: 8
                                font.bold: true
                            }
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 3
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: navItem.modelData.icon
                                color: navItem.selected ? Colors.color(4) : Colors.textMuted
                                font.family: Appearance.iconFont
                                font.pixelSize: 18
                            }
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: navItem.modelData.title
                                color: navItem.selected ? Colors.foreground : Colors.textMuted
                                font.family: Appearance.fontFamily
                                font.pixelSize: 10
                                font.weight: navItem.selected ? Font.DemiBold : Font.Medium
                            }
                        }

                        MouseArea {
                            id: navMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.page = navItem.modelData.key
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "FLUID"
                color: Colors.textDim
                font.family: Appearance.fontFamily
                font.pixelSize: 9
                font.weight: Font.Bold
                font.letterSpacing: 1.2
            }
        }
    }

    Item {
        id: mainContent
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: 520
        implicitHeight: 520

        Item {
            id: header
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 66

            Column {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                Text {
                    text: root.page === "home" ? "Control Center" : root.pageTitle
                    color: Colors.foreground
                    font.family: Appearance.fontFamily
                    font.pixelSize: 21
                    font.weight: Font.Bold
                }
                Text {
                    text: root.page === "home"
                        ? Qt.formatDateTime(new Date(), "dddd, MMM d · hh:mm AP")
                        : (root.page === "notifications" ? `${Notifications.count} unread notifications` : "Quick configuration & controls")
                    color: Colors.color(7)
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSizeSmall
                }
            }

            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 92
                height: 32
                radius: 16
                color: Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.12)
                Row {
                    anchors.centerIn: parent
                    spacing: 6
                    Rectangle { anchors.verticalCenter: parent.verticalCenter; width: 6; height: 6; radius: 3; color: GameMode.active ? Colors.color(1) : Colors.color(4) }
                    Text {
                        text: GameMode.active ? "PERFORMANCE" : "READY"
                        color: Colors.foreground
                        font.family: Appearance.fontFamily
                        font.pixelSize: 9
                        font.weight: Font.Bold
                        font.letterSpacing: 0.6
                    }
                }
            }
        }

        Loader {
            id: pageLoader
            anchors.top: header.bottom
            anchors.topMargin: 12
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            sourceComponent: root.page === "notifications" ? notificationsPage
                : root.page === "audio" ? audioPage
                : root.page === "wifi" ? wifiPage
                : root.page === "bluetooth" ? bluetoothPage
                : root.page === "system" ? systemPage
                : root.page === "settings" ? settingsPage : overview
            opacity: 1
            y: 0
            onSourceComponentChanged: pageTransition.restart()
        }

        SequentialAnimation {
            id: pageTransition
            PropertyAction { target: pageLoader; property: "opacity"; value: 0.55 }
            PropertyAction { target: pageLoader; property: "y"; value: 6 }
            ParallelAnimation {
                NumberAnimation { target: pageLoader; property: "opacity"; to: 1; duration: Appearance.animFast }
                NumberAnimation { target: pageLoader; property: "y"; to: 0; duration: Appearance.animNormal; easing.type: Easing.OutCubic }
            }
        }
    }

    Component {
        id: overview
        RowLayout {
            spacing: 14

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: quickContent.implicitHeight + 26
                    radius: Appearance.radiusLarge
                    color: Qt.rgba(1, 1, 1, 0.035)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.07)

                    ColumnLayout {
                        id: quickContent
                        anchors.fill: parent
                        anchors.margins: 13
                        spacing: 10
                        SectionLabel { icon: "󰐥"; text: "Quick Settings" }
                        GridLayout {
                            Layout.fillWidth: true
                            columns: 2
                            columnSpacing: 8
                            rowSpacing: 8
                            QuickToggle {
                                Layout.fillWidth: true
                                icon: "󰤨"; label: "Wi-Fi"; active: Networking.wifiEnabled
                                subLabel: Networking.wifiEnabled ? (root.wifiDevice?.networks.values.find(n => n.connected)?.name ?? "Enabled") : "Disabled"
                                onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
                            }
                            QuickToggle {
                                Layout.fillWidth: true
                                icon: "󰂯"; label: "Bluetooth"; active: Bluetooth.defaultAdapter?.enabled ?? false
                                subLabel: Bluetooth.defaultAdapter ? (Bluetooth.defaultAdapter.enabled ? "Enabled" : "Disabled") : "Unavailable"
                                onClicked: if (Bluetooth.defaultAdapter) Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled
                            }
                            QuickToggle {
                                Layout.fillWidth: true
                                icon: Notifications.dnd ? "󰂛" : "󰂚"; label: "Notifications"
                                active: !Notifications.dnd
                                subLabel: Notifications.dnd ? "Muted (DND)" : (Notifications.count > 0 ? `${Notifications.count} unread` : "Alerts On")
                                onClicked: root.page = "notifications"
                            }
                            QuickToggle {
                                Layout.fillWidth: true
                                icon: Caffeine.active ? "󰅶" : "󰾪"; label: "Caffeine"
                                active: Caffeine.active
                                subLabel: Caffeine.active ? "Screen Awake" : "Normal Sleep"
                                onClicked: Caffeine.toggle()
                            }
                            QuickToggle {
                                Layout.fillWidth: true
                                icon: "󰊴"; label: "Game Mode"; active: GameMode.active; interactive: false
                                subLabel: GameMode.active ? "Active" : "Idle"
                            }
                            QuickToggle {
                                Layout.fillWidth: true
                                icon: "󰓅"; label: "Power Profile"
                                active: GameMode.active
                                subLabel: GameMode.active ? "Performance" : "Balanced"
                                onClicked: root.page = "system"
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 142
                    radius: Appearance.radiusLarge
                    color: Qt.rgba(1, 1, 1, 0.035)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.07)

                    ColumnLayout {
                        id: controlContent
                        anchors.fill: parent
                        anchors.margins: 13
                        spacing: 11

                        RowLayout {
                            Layout.fillWidth: true
                            SectionLabel { icon: "󰕾"; text: "Quick Controls"; Layout.fillWidth: true }
                            Text {
                                text: "Audio & Media ›"
                                color: Colors.color(4)
                                font.family: Appearance.fontFamily
                                font.pixelSize: Appearance.fontSizeSmall
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.page = "audio" }
                            }
                        }

                        readonly property PwNode sink: Pipewire.defaultAudioSink
                        PwObjectTracker { objects: [controlContent.sink] }

                        Text {
                            visible: !controlContent.sink?.audio
                            text: "No audio output device is available. Check that PipeWire is running."
                            color: Colors.color(7)
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSizeSmall
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }
                        GlassSlider {
                            visible: !!controlContent.sink?.audio
                            Layout.fillWidth: true
                            icon: "󰕾"
                            value: controlContent.sink?.audio?.volume ?? 0
                            onMoved: value => { if (controlContent.sink?.audio) controlContent.sink.audio.volume = value }
                        }
                        Text {
                            visible: !root.brightnessAvailable
                            text: "No display brightness control is available."
                            color: Colors.color(7)
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSizeSmall
                            Layout.fillWidth: true
                        }
                        GlassSlider {
                            id: brightnessSlider
                            visible: root.brightnessAvailable
                            Layout.fillWidth: true
                            icon: "󰃟"
                            from: 1
                            to: 100
                            value: 50
                            onMoved: value => { brightnessSet.command = ["brightnessctl", "set", Math.round(value) + "%"]; brightnessSet.running = true }
                        }
                        Process {
                            id: brightnessGet
                            command: ["brightnessctl", "-m"]
                            running: true
                            stdout: StdioCollector {
                                onStreamFinished: {
                                    const match = this.text.match(/^[^,\n]+,backlight,[^,\n]*,(\d+)%/m);
                                    root.brightnessAvailable = !!match;
                                    if (match) brightnessSlider.value = Number(match[1]);
                                }
                            }
                        }
                        Process { id: brightnessSet }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: devicesContent.implicitHeight + 28
                    radius: Appearance.radiusLarge
                    color: Qt.rgba(1, 1, 1, 0.035)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.07)
                    ColumnLayout {
                        id: devicesContent
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 8
                        Text { text: "YOUR DEVICES & ALERTS"; color: Colors.color(7); font.family: Appearance.fontFamily; font.pixelSize: 10; font.bold: true; font.letterSpacing: 1 }

                        // Notifications row
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            Rectangle {
                                Layout.preferredWidth: 34; Layout.preferredHeight: 34; radius: 12
                                color: Qt.rgba(Colors.color(1).r, Colors.color(1).g, Colors.color(1).b, 0.15)
                                Text { anchors.centerIn: parent; text: Notifications.dnd ? "󰂛" : "󰂚"; color: Colors.color(1); font.family: Appearance.iconFont; font.pixelSize: 17 }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Text { text: "Notifications"; color: Colors.foreground; font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSize; font.bold: true }
                                Text { text: Notifications.dnd ? "Muted (Do Not Disturb)" : (Notifications.count > 0 ? `${Notifications.count} active alerts` : "All caught up"); color: Colors.color(7); font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSizeSmall }
                            }
                            Text { text: "›"; color: Colors.color(7); font.pixelSize: 20 }
                            TapHandler { onTapped: root.page = "notifications" }
                        }

                        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Qt.rgba(1, 1, 1, 0.08) }

                        // Network row
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            Rectangle {
                                Layout.preferredWidth: 34; Layout.preferredHeight: 34; radius: 12
                                color: Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.15)
                                Text { anchors.centerIn: parent; text: Networking.wifiEnabled ? "󰤨" : "󰤭"; color: Colors.color(4); font.family: Appearance.iconFont; font.pixelSize: 17 }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Text { text: "Network"; color: Colors.foreground; font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSize; font.bold: true }
                                Text { text: Networking.wifiEnabled ? (root.wifiDevice?.networks.values.find(n => n.connected)?.name ?? "Wi-Fi enabled") : "Wi-Fi disabled"; color: Colors.color(7); font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSizeSmall; elide: Text.ElideRight; Layout.fillWidth: true }
                            }
                            Text { text: "›"; color: Colors.color(7); font.pixelSize: 20 }
                            TapHandler { onTapped: root.page = "wifi" }
                        }

                        Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Qt.rgba(1, 1, 1, 0.08) }

                        // Bluetooth row
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            Rectangle {
                                Layout.preferredWidth: 34; Layout.preferredHeight: 34; radius: 12
                                color: Qt.rgba(Colors.color(6).r, Colors.color(6).g, Colors.color(6).b, 0.13)
                                Text { anchors.centerIn: parent; text: "󰂯"; color: Colors.color(6); font.family: Appearance.iconFont; font.pixelSize: 17 }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Text { text: "Bluetooth"; color: Colors.foreground; font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSize; font.bold: true }
                                Text { text: Bluetooth.defaultAdapter ? (Bluetooth.defaultAdapter.enabled ? `${Bluetooth.defaultAdapter.devices.values.filter(d => d.connected).length} connected` : "Turned off") : "Adapter unavailable"; color: Colors.color(7); font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSizeSmall }
                            }
                            Text { text: "›"; color: Colors.color(7); font.pixelSize: 20 }
                            TapHandler { onTapped: root.page = "bluetooth" }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 174
                    radius: Appearance.radiusLarge
                    color: Qt.rgba(1, 1, 1, 0.035)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.07)
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 11
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "System overview"; color: Colors.foreground; font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSize + 1; font.bold: true; Layout.fillWidth: true }
                            Text { text: "Open ›"; color: Colors.color(4); font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSizeSmall }
                        }
                        GaugeCard { Layout.fillWidth: true; Layout.fillHeight: true; icon: "󰍛"; label: "CPU usage"; value: SysMonitor.cpuUsage; unit: "%"; accent: Colors.color(1) }
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Do Not Disturb"; color: Colors.textMuted; font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSizeSmall; Layout.fillWidth: true }
                            Text { text: Notifications.dnd ? "On" : "Off"; color: Notifications.dnd ? Colors.color(4) : Colors.color(7); font.family: Appearance.fontFamily; font.pixelSize: Appearance.fontSizeSmall; font.bold: true }
                        }
                    }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.page = "system" }
                }
            }
        }
    }

    Component { id: notificationsPage; NotificationsPage {} }
    Component { id: audioPage; AudioPage {} }
    Component { id: wifiPage; WifiPage {} }
    Component { id: bluetoothPage; BluetoothPage {} }
    Component { id: systemPage; SystemPage {} }
    Component { id: settingsPage; SettingsPage { onNavigate: page => root.page = page } }
}
