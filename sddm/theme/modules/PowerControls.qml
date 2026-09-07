import QtQuick
import QtQuick.Layouts

import ".."

Item {
    id: root

    RowLayout {
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        anchors.margins: 24

        spacing: 14

        Text {
            visible: sddm.canSuspend

            text: "󰤄"

            color: Theme.fg

            font.family: Theme.fontFamily
            font.pixelSize: 22

            MouseArea {
                anchors.fill: parent

                hoverEnabled: true

                cursorShape: Qt.PointingHandCursor

                onClicked: sddm.suspend()
            }
        }

        Text {
            visible: sddm.canReboot

            text: "󰜉"

            color: Theme.fg

            font.family: Theme.fontFamily
            font.pixelSize: 22

            MouseArea {
                anchors.fill: parent

                hoverEnabled: true

                cursorShape: Qt.PointingHandCursor

                onClicked: sddm.reboot()
            }
        }

        Text {
            visible: sddm.canPowerOff

            text: "󰐥"

            color: Theme.fg

            font.family: Theme.fontFamily
            font.pixelSize: 22

            MouseArea {
                anchors.fill: parent

                hoverEnabled: true

                cursorShape: Qt.PointingHandCursor

                onClicked: sddm.powerOff()
            }
        }
    }
}
