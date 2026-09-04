import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services

Scope {
    id: root

    property var active: []

    function makeEntry(notification) {
        return {
            notification: notification,
            closing: false
        };
    }

    Connections {
        target: Notifications
        function onPopup(notification) {
            root.active = [...root.active, root.makeEntry(notification)];
        }
    }

    // Marks an entry as closing so its delegate can animate out,
    // then actually drops it from the model once the animation finishes.
    function closeEntry(entry) {
        root.active = root.active.map(e => e === entry ? Object.assign({}, e, {
                closing: true
            }) : e);
    }

    function removeEntry(entry) {
        root.active = root.active.filter(e => e !== entry);
    }

    PanelWindow {
        id: win
        visible: root.active.length > 0
        color: "transparent"
        exclusiveZone: 0
        WlrLayershell.namespace: "quickshell:toasts"

        anchors {
            top: true
            right: true
        }

        implicitWidth: 340
        implicitHeight: col.implicitHeight + 24

        ColumnLayout {
            id: col
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 12
            width: 316
            spacing: 8

            Repeater {
                model: root.active

                delegate: Rectangle {
                    id: toast
                    required property var modelData

                    readonly property bool closing: modelData.closing
                    property bool entered: false

                    Layout.fillWidth: true
                    implicitHeight: toastCol.implicitHeight + 24
                    radius: 16
                    color: Colors.background
                    border.width: 1
                    border.color: Colors.color(4)

                    opacity: !entered ? 0 : (closing ? 0 : 0.97)
                    scale: !entered ? 0.9 : (closing ? 0.85 : 1.0)

                    transform: Translate {
                        id: slide
                        x: toast.entered && !toast.closing ? 0 : 24
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
                    Behavior on x {
                        // no-op guard removed; slide handled via transform above
                    }

                    Component.onCompleted: entered = true

                    onClosingChanged: if (closing)
                        closeTimer.start()

                    Timer {
                        id: closeTimer
                        interval: Appearance.animNormal
                        onTriggered: root.removeEntry(toast.modelData)
                    }

                    Timer {
                        interval: toast.modelData.notification.expireTimeout > 0 ? toast.modelData.notification.expireTimeout : 1000
                        running: true
                        onTriggered: root.closeEntry(toast.modelData)
                    }

                    ColumnLayout {
                        id: toastCol
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 2

                        Text {
                            text: toast.modelData.notification.appName
                            color: Colors.color(7)
                            font.pixelSize: 11
                            font.family: Appearance.fontFamily
                            font.weight: Font.Bold
                        }
                        Text {
                            text: toast.modelData.notification.summary
                            color: Colors.foreground
                            font.bold: true
                            font.family: Appearance.fontFamily
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                            font.weight: Font.Bold
                        }
                        Text {
                            visible: toast.modelData.notification.body.length > 0
                            text: toast.modelData.notification.body
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
                        onClicked: root.closeEntry(toast.modelData)
                    }
                }
            }
        }
    }
}
