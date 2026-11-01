import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import qs.config
import qs.config.components
import qs.services

ColumnLayout {
    id: root
    spacing: 12

    readonly property var notifications: Notifications.list ? Notifications.list.values : []
    readonly property int count: notifications.length

    // Top action bar: count, DND toggle, Clear All
    RowLayout {
        Layout.fillWidth: true
        spacing: 10

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            Text {
                text: "Notifications"
                color: Colors.foreground
                font.family: Appearance.fontFamily
                font.pixelSize: Appearance.fontSize + 2
                font.bold: true
            }
            Text {
                text: root.count > 0 
                    ? `${root.count} active ${root.count === 1 ? "notification" : "notifications"}`
                    : "No unread notifications"
                color: Colors.color(7)
                font.family: Appearance.fontFamily
                font.pixelSize: Appearance.fontSizeSmall
            }
        }

        GlassButton {
            icon: Notifications.dnd ? "󰂛" : "󰂚"
            text: Notifications.dnd ? "Muted" : "DND"
            accent: Notifications.dnd
            onClicked: Notifications.toggleDnd()
        }

        GlassButton {
            visible: root.count > 0
            icon: "󰅖"
            text: "Clear All"
            accent: false
            onClicked: Notifications.clearAll()
        }
    }

    // Empty state
    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: root.count === 0
        radius: Appearance.radiusLarge
        color: Qt.rgba(1, 1, 1, 0.035)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.07)

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 12

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 64
                height: 64
                radius: 32
                color: Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.12)
                border.width: 1
                border.color: Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.28)

                Text {
                    anchors.centerIn: parent
                    text: Notifications.dnd ? "󰂛" : "󰂚"
                    color: Colors.color(4)
                    font.family: Appearance.iconFont
                    font.pixelSize: 28
                }
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 4

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: Notifications.dnd ? "Do Not Disturb is Active" : "All Caught Up"
                    color: Colors.foreground
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSize + 2
                    font.bold: true
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: Notifications.dnd 
                        ? "Notification alerts are silenced."
                        : "New notifications from your apps will appear here."
                    color: Colors.textMuted
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSizeSmall
                }
            }
        }
    }

    // Notification List
    ListView {
        id: notifList
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: root.count > 0
        clip: true
        spacing: 8
        model: root.notifications

        delegate: Rectangle {
            id: itemCard
            required property var modelData
            required property int index

            readonly property color accentColor: modelData.urgency === NotificationUrgency.Critical 
                ? "#f38ba8" 
                : Colors.color(4)

            width: notifList.width
            implicitHeight: itemContent.implicitHeight + 20
            radius: Appearance.radiusMedium
            color: itemHover.hovered ? Qt.rgba(1, 1, 1, 0.065) : Qt.rgba(1, 1, 1, 0.04)
            border.width: 1
            border.color: modelData.urgency === NotificationUrgency.Critical
                ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.5)
                : Qt.rgba(1, 1, 1, 0.07)

            Behavior on color { ColorAnimation { duration: Appearance.animFast } }

            // Urgency accent stripe on left
            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 6
                width: 3
                radius: 2
                color: itemCard.accentColor
            }

            ColumnLayout {
                id: itemContent
                anchors.fill: parent
                anchors.leftMargin: 18
                anchors.rightMargin: 12
                anchors.topMargin: 10
                anchors.bottomMargin: 10
                spacing: 6

                // Header: App icon / name + Dismiss button
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        radius: 6
                        color: Qt.rgba(itemCard.accentColor.r, itemCard.accentColor.g, itemCard.accentColor.b, 0.18)

                        Text {
                            anchors.centerIn: parent
                            text: itemCard.modelData.urgency === NotificationUrgency.Critical ? "!" : "●"
                            color: itemCard.accentColor
                            font.family: Appearance.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: itemCard.modelData.appName || "System"
                        color: itemCard.accentColor
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSizeSmall
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    // Dismiss single button
                    Rectangle {
                        Layout.preferredWidth: 22
                        Layout.preferredHeight: 22
                        radius: 11
                        color: dismissMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "×"
                            color: dismissMouse.containsMouse ? Colors.foreground : Colors.textMuted
                            font.pixelSize: 16
                            font.bold: true
                        }

                        MouseArea {
                            id: dismissMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Notifications.dismiss(itemCard.modelData)
                        }
                    }
                }

                // Summary
                Text {
                    visible: text.length > 0
                    Layout.fillWidth: true
                    text: itemCard.modelData.summary || ""
                    color: Colors.foreground
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSize
                    font.bold: true
                    elide: Text.ElideRight
                }

                // Body
                Text {
                    visible: text.length > 0
                    Layout.fillWidth: true
                    text: itemCard.modelData.body || ""
                    color: Colors.textMuted
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSizeSmall
                    wrapMode: Text.Wrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                    textFormat: Text.AutoText
                    onLinkActivated: link => Qt.openUrlExternally(link)
                }

                // Action buttons (e.g. Reply, Open, Snooze)
                Flow {
                    Layout.fillWidth: true
                    visible: itemCard.modelData.actions && itemCard.modelData.actions.length > 0
                    spacing: 6

                    Repeater {
                        model: itemCard.modelData.actions

                        Rectangle {
                            required property var modelData
                            implicitWidth: actText.implicitWidth + 18
                            implicitHeight: 26
                            radius: 8
                            color: actMouse.containsMouse 
                                ? Qt.rgba(itemCard.accentColor.r, itemCard.accentColor.g, itemCard.accentColor.b, 0.28)
                                : Qt.rgba(itemCard.accentColor.r, itemCard.accentColor.g, itemCard.accentColor.b, 0.14)

                            Text {
                                id: actText
                                anchors.centerIn: parent
                                text: parent.modelData.text || "Open"
                                color: Colors.foreground
                                font.family: Appearance.fontFamily
                                font.pixelSize: 10
                                font.bold: true
                            }

                            MouseArea {
                                id: actMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    parent.modelData.invoke();
                                    Notifications.dismiss(itemCard.modelData);
                                }
                            }
                        }
                    }
                }
            }

            HoverHandler { id: itemHover }
        }
    }
}
