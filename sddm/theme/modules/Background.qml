import QtQuick
import QtQuick.Effects

import ".."

Item {
    id: root

    Image {
        id: wallpaper

        anchors.fill: parent

        source: config.background ? Qt.resolvedUrl("../" + config.background) : Qt.resolvedUrl("../backgrounds/default.jpg")

        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true

        visible: false
    }

    MultiEffect {
        anchors.fill: wallpaper

        source: wallpaper

        blurEnabled: true
        blurMax: 64
        blur: 0.72

        brightness: -0.08

        autoPaddingEnabled: false
    }

    // Main dark overlay.
    Rectangle {
        anchors.fill: parent

        color: "#000000"
        opacity: 0.38
    }

    // Slightly darker lower edge.
    Rectangle {
        anchors.fill: parent

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#00000015"
            }

            GradientStop {
                position: 0.55
                color: "#00000020"
            }

            GradientStop {
                position: 1.0
                color: "#00000085"
            }
        }
    }

    // Very subtle dark center veil behind the login UI.
    Rectangle {
        anchors.fill: parent

        color: Theme.bg
        opacity: 0.08
    }
}
