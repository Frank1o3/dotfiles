import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Basic

import ".."
import "../components"

Item {
    id: root

    width: card.width
    height: card.height

    GlassCard {
        id: card

        width: 340
        height: loginCol.implicitHeight + 40

        anchors.centerIn: parent

        ColumnLayout {
            id: loginCol

            anchors.fill: parent
            anchors.margins: 20

            spacing: 12

            ComboBox {
                id: userCombo

                Layout.fillWidth: true

                model: userModel
                textRole: "name"

                currentIndex: userModel.lastIndex

                font.family: Theme.fontFamily

                background: Rectangle {
                    radius: 10

                    color: Theme.input

                    border.width: 1

                    border.color: userCombo.activeFocus ? Theme.accent : Theme.inputBorder
                }

                contentItem: Text {
                    text: userCombo.displayText

                    color: Theme.fg

                    font.family: Theme.fontFamily
                    font.pixelSize: 13

                    verticalAlignment: Text.AlignVCenter

                    leftPadding: 10
                    rightPadding: 10
                }
            }

            TextField {
                id: passwordField

                Layout.fillWidth: true

                echoMode: TextInput.Password

                placeholderText: "Password"

                font.family: Theme.fontFamily

                color: Theme.fg

                placeholderTextColor: Qt.rgba(Theme.fg.r, Theme.fg.g, Theme.fg.b, 0.45)

                background: Rectangle {
                    radius: 10

                    color: Theme.input

                    border.width: 1

                    border.color: passwordField.activeFocus ? Theme.accent : Theme.inputBorder
                }

                onAccepted: login()

                focus: true
            }

            ComboBox {
                id: sessionCombo

                Layout.fillWidth: true

                model: sessionModel
                textRole: "name"

                currentIndex: sessionModel.lastIndex

                font.family: Theme.fontFamily

                background: Rectangle {
                    radius: 10

                    color: Theme.input

                    border.width: 1

                    border.color: sessionCombo.activeFocus ? Theme.accent : Theme.inputBorder
                }

                contentItem: Text {
                    text: sessionCombo.displayText

                    color: Theme.fg

                    font.family: Theme.fontFamily
                    font.pixelSize: 13

                    verticalAlignment: Text.AlignVCenter

                    leftPadding: 10
                    rightPadding: 10
                }
            }

            Text {
                id: errorLabel

                text: ""

                color: Theme.error

                font.family: Theme.fontFamily
                font.pixelSize: 12

                Layout.alignment: Qt.AlignHCenter

                visible: text.length > 0
            }

            Button {
                id: loginButton

                Layout.fillWidth: true

                text: "Log In"

                font.family: Theme.fontFamily

                background: Rectangle {
                    radius: 10

                    color: loginButton.pressed ? Qt.darker(Theme.accent, 1.1) : Theme.accent
                }

                onClicked: login()
            }
        }
    }

    function login() {
        sddm.login(userCombo.currentText, passwordField.text, sessionCombo.currentIndex);
    }

    Connections {
        target: sddm

        function onLoginFailed() {
            errorLabel.text = "Login failed — try again";

            passwordField.text = "";
            passwordField.forceActiveFocus();
        }
    }

    Component.onCompleted: {
        passwordField.forceActiveFocus();
    }
}
