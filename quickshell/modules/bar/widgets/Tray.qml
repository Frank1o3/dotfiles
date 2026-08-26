import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import Quickshell.Services.SystemTray
import qs.config

RowLayout {
    spacing: 6

    Repeater {
        model: SystemTray.items

        delegate: Item {
            id: trayItem
            required property var modelData

            implicitWidth: 18
            implicitHeight: 18

            Image {
                anchors.fill: parent
                source: trayItem.modelData.icon
                fillMode: Image.PreserveAspectFit
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: mouse => {
                    if (mouse.button === Qt.LeftButton) {
                        trayItem.modelData.activate();
                    } else if (mouse.button === Qt.RightButton) {
                        trayItem.modelData.display(Window.window, mouse.x, mouse.y);
                    } else {
                        trayItem.modelData.secondaryActivate();
                    }
                }
            }
        }
    }
}
