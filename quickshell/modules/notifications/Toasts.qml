import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs.config
import qs.services

Scope {
    id: root
    property var toastItems: []

    Connections {
        target: Notifications
        function onPopup(notification) {
            // Keep the toast stack readable when an app sends a burst.
            if (root.toastItems.length >= 4)
                root.toastItems.shift().destroy();
            const toast = toastComponent.createObject(col, { notification: notification });
            if (toast)
                root.toastItems = root.toastItems.concat([toast]);
        }
    }

    PanelWindow {
        id: win
        visible: col.children.length > 0
        color: "transparent"
        exclusiveZone: 0
        WlrLayershell.namespace: "quickshell:toasts"

        anchors {
            top: true
            right: true
        }
        margins {
            top: Appearance.barHeight + 16
            right: 16
        }

        implicitWidth: 400
        implicitHeight: Math.min(col.implicitHeight + 12, (screen?.height ?? 1080) - Appearance.barHeight - 32)

        Column {
            id: col
            anchors.top: parent.top
            anchors.right: parent.right
            width: 380
            spacing: 9
        }
    }

    Component {
        id: toastComponent

        Rectangle {
            id: toast
            required property var notification

            property bool entered: false
            property bool closing: false
            property real remaining: 1
            readonly property color accent: notification.urgency === NotificationUrgency.Critical ? "#f38ba8" : Colors.color(4)

            width: parent ? parent.width : 380
            implicitHeight: content.implicitHeight + 24
            radius: Appearance.radiusLarge
            color: GameMode.active ? "#f20e1018" : Qt.rgba(0.06, 0.07, 0.10, 0.96)
            border.width: notification.urgency === NotificationUrgency.Critical ? 2 : 1
            border.color: notification.urgency === NotificationUrgency.Critical ? accent : Qt.rgba(accent.r, accent.g, accent.b, 0.42)

            opacity: entered && !closing ? 1 : 0
            scale: entered && !closing ? 1 : 0.94
            transform: Translate { x: toast.entered && !toast.closing ? 0 : 34 }
            Behavior on opacity { NumberAnimation { duration: Appearance.animNormal; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: Appearance.animNormal; easing.type: Easing.OutCubic } }
            Behavior on border.color { ColorAnimation { duration: Appearance.animFast } }

            Component.onCompleted: entered = true
            Component.onDestruction: root.toastItems = root.toastItems.filter(item => item !== toast)

            function close(dismissNotification) {
                if (closing)
                    return;
                closing = true;
                if (dismissNotification && notification)
                    notification.dismiss();
                destroyTimer.start();
            }

            function timeoutForNotification() {
                if (notification.expireTimeout > 0)
                    return notification.expireTimeout;
                if (notification.urgency === NotificationUrgency.Critical)
                    return 10000;
                if (notification.urgency === NotificationUrgency.Low)
                    return 3500;
                return 6500;
            }

            NumberAnimation on remaining {
                running: toast.entered && !toast.closing && !hover.hovered && !GameMode.active
                from: toast.remaining
                to: 0
                duration: Math.max(1, toast.timeoutForNotification() * toast.remaining)
                onFinished: if (toast.remaining <= 0.001) toast.close(false)
            }

            Timer {
                interval: toast.timeoutForNotification()
                running: toast.entered && !toast.closing && !hover.hovered && GameMode.active
                onTriggered: toast.close(false)
            }

            Timer {
                id: destroyTimer
                interval: Math.max(1, Appearance.animNormal)
                onTriggered: toast.destroy()
            }

            // Thin accent marker gives urgency a clear visual cue without a
            // layered drop shadow or a full-card graphical effect.
            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 12
                width: 4
                radius: 2
                color: toast.accent
            }

            ColumnLayout {
                id: content
                anchors.fill: parent
                anchors.leftMargin: 26
                anchors.rightMargin: 12
                anchors.topMargin: 12
                anchors.bottomMargin: 12
                spacing: 7

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        radius: 10
                        color: Qt.rgba(toast.accent.r, toast.accent.g, toast.accent.b, 0.16)
                        Text {
                            anchors.centerIn: parent
                            text: toast.notification.urgency === NotificationUrgency.Critical ? "!" : "●"
                            color: toast.accent
                            font.family: Appearance.fontFamily
                            font.pixelSize: 13
                            font.bold: true
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: toast.notification.appName || "Notification"
                        color: toast.accent
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSizeSmall
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }

                    Rectangle {
                        Layout.preferredWidth: 26
                        Layout.preferredHeight: 26
                        radius: 13
                        color: closeMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.13) : "transparent"
                        Text { anchors.centerIn: parent; text: "×"; color: Colors.textMuted; font.pixelSize: 18 }
                        MouseArea {
                            id: closeMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: toast.close(true)
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: toast.notification.summary || ""
                    color: Colors.foreground
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSize + 1
                    font.weight: Font.DemiBold
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    visible: text.length > 0
                    text: toast.notification.body || ""
                    color: Colors.textMuted
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSizeSmall
                    wrapMode: Text.Wrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                    textFormat: Text.AutoText
                    onLinkActivated: link => Qt.openUrlExternally(link)
                }

                Flow {
                    Layout.fillWidth: true
                    visible: toast.notification.actions.length > 0
                    spacing: 6
                    Repeater {
                        model: toast.notification.actions
                        Rectangle {
                            required property var modelData
                            implicitWidth: actionLabel.implicitWidth + 24
                            implicitHeight: 30
                            radius: 10
                            color: actionMouse.containsMouse ? Qt.rgba(toast.accent.r, toast.accent.g, toast.accent.b, 0.27) : Qt.rgba(toast.accent.r, toast.accent.g, toast.accent.b, 0.15)
                            Text {
                                id: actionLabel
                                anchors.centerIn: parent
                                text: modelData.text || "Open"
                                color: Colors.foreground
                                font.family: Appearance.fontFamily
                                font.pixelSize: Appearance.fontSizeSmall
                                font.weight: Font.DemiBold
                            }
                            MouseArea {
                                id: actionMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    modelData.invoke();
                                    toast.close(false);
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    visible: toast.notification.expireTimeout > 0
                    Layout.fillWidth: true
                    Layout.preferredHeight: 2
                    radius: 1
                    color: Qt.rgba(1, 1, 1, 0.09)
                    Rectangle {
                        width: parent.width * toast.remaining
                        height: parent.height
                        radius: 1
                        color: toast.accent
                        opacity: 0.7
                    }
                }
            }

            HoverHandler { id: hover }
        }
    }
}
