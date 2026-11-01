import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam
import Quickshell.Services.Mpris
import Quickshell.Services.UPower
import qs.config
import qs.config.components
import qs.services

Scope {
    id: root

    property string errorMessage: ""
    readonly property string currentUser: Quickshell.env("USER") || "user"
    readonly property MprisPlayer activePlayer: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
    readonly property UPowerDevice bat: UPower.displayDevice

    IpcHandler {
        target: "lockscreen"

        function lock(): void {
            sessionLock.locked = true;
        }

        function unlock(): void {
            sessionLock.unlock();
        }

        function toggle(): void {
            if (sessionLock.locked) sessionLock.unlock();
            else sessionLock.locked = true;
        }
    }

    PamContext {
        id: pam
        user: root.currentUser
        config: "login"

        onCompleted: result => {
            if (result === PamResult.Success) {
                root.errorMessage = "";
                sessionLock.unlock();
            } else {
                root.errorMessage = "Incorrect password";
                pam.start();
            }
        }

        onError: err => {
            root.errorMessage = PamError.toString(err);
            pam.start();
        }
    }

    WlSessionLock {
        id: sessionLock

        onLockedChanged: {
            if (locked) {
                root.errorMessage = "";
                pam.start();
            }
        }

        surface: WlSessionLockSurface {
            id: lockSurface

            Rectangle {
                anchors.fill: parent
                color: "#0a0b12"

                // Optional blurred wallpaper background
                Image {
                    anchors.fill: parent
                    source: Colors.wallpaper ? `file://${Colors.wallpaper}` : ""
                    fillMode: Image.PreserveAspectCrop
                    opacity: 0.28
                    visible: Colors.wallpaper.length > 0
                }

                // Dark atmospheric gradient overlay
                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.rgba(0.04, 0.05, 0.08, 0.88) }
                        GradientStop { position: 0.5; color: Qt.rgba(0.04, 0.05, 0.08, 0.94) }
                        GradientStop { position: 1.0; color: Qt.rgba(0.02, 0.03, 0.05, 0.98) }
                    }
                }

                // Top Status Bar: Battery & Power Info
                RowLayout {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 28
                    spacing: 12

                    // System name / lock tag
                    Row {
                        spacing: 8
                        Rectangle {
                            width: 24; height: 24; radius: 12
                            color: Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.20)
                            Text { anchors.centerIn: parent; text: "󰌾"; color: Colors.color(4); font.family: Appearance.iconFont; font.pixelSize: 12 }
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "LOCKED SESSION"
                            color: Colors.color(7)
                            font.family: Appearance.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 1.2
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Laptop Battery widget (if present)
                    Row {
                        visible: root.bat?.isLaptopBattery ?? false
                        spacing: 6
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: (root.bat?.state === UPowerDeviceState.Charging) ? "󰂄" : "󰁹"
                            color: (root.bat?.state === UPowerDeviceState.Charging) ? Colors.color(4) : Colors.foreground
                            font.family: Appearance.iconFont
                            font.pixelSize: 14
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: `${Math.round((root.bat?.percentage ?? 0) * 100)}%`
                            color: Colors.foreground
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSizeSmall
                            font.bold: true
                        }
                    }
                }

                // Center Clock, Date, Avatar & Authentication Box
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 20
                    width: Math.min(420, parent.width - 48)

                    // Big Clock & Date
                    ColumnLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 4

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: Qt.formatDateTime(new Date(), "hh:mm")
                            color: Colors.foreground
                            font.family: Appearance.fontFamily
                            font.pixelSize: 76
                            font.weight: Font.Bold
                            font.letterSpacing: -1
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: Qt.formatDateTime(new Date(), "dddd, MMMM d")
                            color: Colors.color(7)
                            font.family: Appearance.fontFamily
                            font.pixelSize: Appearance.fontSizeLarge
                            font.weight: Font.Medium
                        }

                        Timer {
                            interval: 1000
                            running: sessionLock.locked
                            repeat: true
                            onTriggered: {
                                // Forces re-evaluation of date bindings every second
                                parent.children[0].text = Qt.formatDateTime(new Date(), "hh:mm");
                                parent.children[1].text = Qt.formatDateTime(new Date(), "dddd, MMMM d");
                            }
                        }
                    }

                    Item { Layout.preferredHeight: 12 }

                    // Glass Login Card
                    GlassCard {
                        Layout.fillWidth: true
                        implicitHeight: loginForm.implicitHeight + 40
                        cardRadius: Appearance.radiusLarge
                        surfaceOpacity: 0.88
                        borderColor: root.errorMessage.length > 0 ? "#f38ba8" : Qt.rgba(1, 1, 1, 0.16)

                        ColumnLayout {
                            id: loginForm
                            anchors.fill: parent
                            anchors.margins: 22
                            spacing: 14

                            // User Pill
                            RowLayout {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 10

                                Rectangle {
                                    width: 38; height: 38; radius: 19
                                    color: Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.22)
                                    border.width: 1
                                    border.color: Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.45)
                                    Text {
                                        anchors.centerIn: parent
                                        text: root.currentUser.slice(0, 1).toUpperCase()
                                        color: Colors.color(4)
                                        font.family: Appearance.fontFamily
                                        font.pixelSize: 16
                                        font.bold: true
                                    }
                                }

                                Text {
                                    text: root.currentUser
                                    color: Colors.foreground
                                    font.family: Appearance.fontFamily
                                    font.pixelSize: Appearance.fontSizeLarge
                                    font.bold: true
                                }
                            }

                            // Password Input Field
                            TextField {
                                id: passwordInput
                                Layout.fillWidth: true
                                Layout.preferredHeight: 48
                                focus: sessionLock.locked
                                verticalAlignment: TextInput.AlignVCenter
                                leftPadding: 16
                                rightPadding: 44
                                color: Colors.foreground
                                font.family: Appearance.fontFamily
                                font.pixelSize: Appearance.fontSize + 1
                                echoMode: TextInput.Password
                                passwordCharacter: "●"
                                placeholderText: "Enter password"
                                placeholderTextColor: Qt.rgba(1, 1, 1, 0.40)
                                clip: true

                                background: Rectangle {
                                    radius: 12
                                    color: Qt.rgba(1, 1, 1, 0.07)
                                    border.width: 1
                                    border.color: root.errorMessage.length > 0
                                        ? "#f38ba8"
                                        : (passwordInput.activeFocus ? Colors.color(4) : Qt.rgba(1, 1, 1, 0.12))
                                }

                                onAccepted: {
                                    if (passwordInput.text.length > 0) {
                                        root.errorMessage = "";
                                        pam.respond(passwordInput.text);
                                        passwordInput.text = "";
                                    }
                                }

                                // Unlock submit icon button inside field
                                Rectangle {
                                    anchors.right: parent.right
                                    anchors.rightMargin: 6
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 34; height: 34; radius: 17
                                    color: submitMouse.containsMouse ? Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.35) : Qt.rgba(1, 1, 1, 0.06)

                                    Text {
                                        anchors.centerIn: parent
                                        text: "➔"
                                        color: Colors.foreground
                                        font.pixelSize: 13
                                    }

                                    MouseArea {
                                        id: submitMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: passwordInput.accepted()
                                    }
                                }
                            }

                            // Error Message
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                visible: root.errorMessage.length > 0
                                text: root.errorMessage
                                color: "#f38ba8"
                                font.family: Appearance.fontFamily
                                font.pixelSize: Appearance.fontSizeSmall
                                font.bold: true
                            }
                        }
                    }

                    // Active Media Player Pill (if audio is currently playing)
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        visible: root.activePlayer !== null
                        width: Math.min(360, parent.width)
                        height: 48
                        radius: 24
                        color: Qt.rgba(1, 1, 1, 0.045)
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.08)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 10

                            Rectangle {
                                width: 28; height: 28; radius: 14
                                color: Qt.rgba(Colors.color(4).r, Colors.color(4).g, Colors.color(4).b, 0.20)
                                Text { anchors.centerIn: parent; text: "󰎆"; color: Colors.color(4); font.family: Appearance.iconFont; font.pixelSize: 13 }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Text {
                                    Layout.fillWidth: true
                                    text: root.activePlayer?.trackTitle || "Media Playback"
                                    color: Colors.foreground
                                    font.family: Appearance.fontFamily
                                    font.pixelSize: 11
                                    font.bold: true
                                    elide: Text.ElideRight
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: root.activePlayer?.trackArtist || root.activePlayer?.identity || ""
                                    color: Colors.color(7)
                                    font.family: Appearance.fontFamily
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                }
                            }

                            // Play/Pause button
                            Rectangle {
                                width: 28; height: 28; radius: 14
                                color: Qt.rgba(1, 1, 1, 0.08)
                                Text {
                                    anchors.centerIn: parent
                                    text: root.activePlayer?.playbackState === MprisPlaybackState.Playing ? "󰏤" : "󰐊"
                                    color: Colors.foreground
                                    font.family: Appearance.iconFont
                                    font.pixelSize: 12
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.activePlayer?.togglePlaying()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
