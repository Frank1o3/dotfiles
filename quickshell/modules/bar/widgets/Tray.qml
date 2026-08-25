import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import qs.config

RowLayout {
    spacing: 6

    Repeater {
        model: SystemTray.items

        delegate: Item {
            id: trayItem // 1. Give the delegate an ID

            required property var modelData // You placed this perfectly!

            implicitWidth: 18
            implicitHeight: 18

            Image {
                anchors.fill: parent
                // 2. Qualify the access with the ID
                source: trayItem.modelData.icon
                fillMode: Image.PreserveAspectFit
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouse => {
                    if (mouse.button === Qt.LeftButton)
                        trayItem.modelData.activate();
                    else
                        // 3. Qualify here too
                        trayItem.modelData.secondaryActivate(); // 4. And here
                }
            }
        }
    }
}
