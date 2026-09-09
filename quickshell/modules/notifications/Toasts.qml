import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects
import Quickshell.Services.Notifications
import qs.config
import qs.services

Scope {
    id: root

    Connections {
        target: Notifications
        function onPopup(notification) {
            toastComponent.createObject(col, {
                notification: notification
            });
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

        implicitWidth: 340
        implicitHeight: col.implicitHeight + 24

        Column {
            id: col
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 12
            width: 316
            spacing: 8
        }
    }

    Component {
        id: toastComponent

        Rectangle {
            id: toast
            required property var notification

            property bool entered: false
            property bool closing: false

            width: parent ? parent.width : 316
            implicitHeight: toastCol.implicitHeight + 24
            radius: 16
            color: Colors.background
            border.color: notification.urgency === NotificationUrgency.Critical ? "#f38ba8" : Colors.color(4)
            border.width: notification.urgency === NotificationUrgency.Critical ? 2 : 1

            opacity: !entered ? 0 : (closing ? 0 : 0.97)
            scale: !entered ? 0.9 : (closing ? 0.85 : 1.0)

            // Layered contact shadow, follows opacity/scale automatically
            // since it's a post-processing layer effect on this item.
            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                radius: Appearance.shadowRadiusSmall
                samples: Appearance.shadowRadiusSmall * 2 + 1
                verticalOffset: Appearance.shadowOffsetSmall
                color: Appearance.shadowColorAmbient
            }

            transform: Translate {
                x: toast.entered && !toast.closing ? 0 : 24
                Behavior on x {
                    NumberAnimation {
                        duration: Appearance.animNormal
                        easing.type: Easing.OutCubic
                    }
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: Appearance.animNormal
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: Appearance.animNormal
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.02
                }
            }

            Component.onCompleted: entered = true

            function close() {
                if (closing)
                    return;
                closing = true;
                destroyTimer.start();
            }

            function defaultDuration() {
                switch (notification.urgency) {
                case NotificationUrgency.Critical:
                    return 10000; // stays noticeably longer
                case NotificationUrgency.Low:
                    return 2500;  // quick, low-friction
                default:
                    return 5000;  // Normal
                }
            }

            Timer {
                id: destroyTimer
                interval: Appearance.animNormal
                onTriggered: toast.destroy()
            }

            Timer {
                interval: toast.notification.expireTimeout > 0 ? toast.notification.expireTimeout : toast.defaultDuration()
                running: true
                onTriggered: toast.close()
            }

            // Glass highlight streak — same language as GlassCard, kept
            // inline here since the toast's border color is dynamic
            // (urgency) which GlassCard doesn't model.
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 1
                height: parent.height * Appearance.glassHighlightHeightRatio
                radius: parent.radius

                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, Appearance.glassHighlightOpacity) }
                    GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0) }
                }
            }

            ColumnLayout {
                id: toastCol
                anchors.fill: parent
                anchors.margins: 12
                spacing: 2

                Text {
                    text: toast.notification.appName
                    color: Colors.color(7)
                    font.pixelSize: 11
                    font.family: Appearance.fontFamily
                    font.weight: Font.Bold
                }
                Text {
                    text: toast.notification.summary
                    color: Colors.foreground
                    font.bold: true
                    font.family: Appearance.fontFamily
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                    font.weight: Font.Bold
                }
                Text {
                    visible: toast.notification.body.length > 0
                    text: toast.notification.body
                    color: Colors.foreground
                    opacity: 0.85
                    font.family: Appearance.fontFamily
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                    font.weight: Font.Bold
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: toast.close()
            }
        }
    }
}
