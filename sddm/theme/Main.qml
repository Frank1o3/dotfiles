import QtQuick 2.15
import "modules"

Item {
    Background {
        anchors.fill: parent
    }

    Clock {
        anchors.fill: parent
    }

    LoginPanel {
        anchors.centerIn: parent
    }

    PowerControls {
        anchors.fill: parent
    }
}
