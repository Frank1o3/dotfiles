import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.services

Scope {
    id: root

    property var active: []

    Connections {
        target: Notifications
        function onPopup(notification) {
            root.active = [...root.active, notification];
        }
    }

    function removeEntry(notification) {
        root.active = root.active.filter(n => n !== notification);
    }

    PanelWindow {
        id: win
        visible: root.active.length > 0
        color: "transparent"
        exclusiveZone: 0

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
                    Layout.fillWidth: true
                    implicitHeight: toastCol.implicitHeight + 24
                    radius: 16
                    color: Colors.background
                    opacity: 0.97
                    border.width: 1
                    border.color: Colors.color(4)

                    Timer {
                        interval: toast.modelData.expireTimeout > 0 ? toast.modelData.expireTimeout : 5000
                        running: true
                        onTriggered: root.removeEntry(toast.modelData)
                    }

                    ColumnLayout {
                        id: toastCol
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 2

                        Text {
                            text: toast.modelData.appName
                            color: Colors.color(7)
                            font.pixelSize: 11
                            font.family: Appearance.fontFamily
                        }
                        Text {
                            text: toast.modelData.summary
                            color: Colors.foreground
                            font.bold: true
                            font.family: Appearance.fontFamily
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }
                        Text {
                            visible: toast.modelData.body.length > 0
                            text: toast.modelData.body
                            color: Colors.foreground
                            opacity: 0.85
                            font.family: Appearance.fontFamily
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.removeEntry(toast.modelData)
                    }
                }
            }
        }
    }
}
