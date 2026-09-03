import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Basic

Item {
    id: root

    readonly property color bg: config.colorBackground || "#1e1e2e"
    readonly property color fg: config.colorForeground || "#cdd6f4"
    readonly property color accent: config.colorAccent || "#89b4fa"
    readonly property color borderCol: config.colorBorder || "#313244"
    readonly property string fontFamily: config.fontFamily || "SpaceMono Nerd Font"

    Image {
        anchors.fill: parent
        source: config.background || "backgrounds/default.jpg"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    // Darkening overlay so text stays legible regardless of wallpaper brightness
    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.35
    }

    property string clockText: ""
    property string dateText: ""

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            const now = new Date();
            root.clockText = Qt.formatTime(now, "hh:mm AP");
            root.dateText = Qt.formatDate(now, "dddd, MMMM d");
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -140
        spacing: 6

        Text {
            text: root.clockText
            color: root.fg
            font.family: root.fontFamily
            font.pixelSize: 72
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }
        Text {
            text: root.dateText
            color: root.fg
            opacity: 0.8
            font.family: root.fontFamily
            font.pixelSize: 18
            Layout.alignment: Qt.AlignHCenter
        }
    }

    Rectangle {
        id: card
        width: 340
        height: loginCol.implicitHeight + 40
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 140
        radius: 20
        color: Qt.rgba(root.bg.r, root.bg.g, root.bg.b, 0.55)
        border.width: 1
        border.color: Qt.rgba(root.borderCol.r, root.borderCol.g, root.borderCol.b, 0.8)

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
                font.family: root.fontFamily
            }

            TextField {
                id: passwordField
                Layout.fillWidth: true
                echoMode: TextInput.Password
                placeholderText: "Password"
                font.family: root.fontFamily
                color: root.fg
                background: Rectangle {
                    radius: 10
                    color: Qt.rgba(1, 1, 1, 0.08)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.12)
                }
                onAccepted: sddm.login(userCombo.currentText, passwordField.text, sessionCombo.currentIndex)
                focus: true
            }

            ComboBox {
                id: sessionCombo
                Layout.fillWidth: true
                model: sessionModel
                textRole: "name"
                currentIndex: sessionModel.lastIndex
                font.family: root.fontFamily
            }

            Text {
                id: errorLabel
                text: ""
                color: "#f38ba8"
                font.family: root.fontFamily
                font.pixelSize: 12
                Layout.alignment: Qt.AlignHCenter
                visible: text.length > 0
            }

            Button {
                Layout.fillWidth: true
                text: "Log In"
                font.family: root.fontFamily
                onClicked: sddm.login(userCombo.currentText, passwordField.text, sessionCombo.currentIndex)
                background: Rectangle {
                    radius: 10
                    color: root.accent
                }
            }
        }
    }

    RowLayout {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 24
        spacing: 14

        Text {
            visible: sddm.canSuspend
            text: "󰤄"
            color: root.fg
            font.pixelSize: 22
            font.family: root.fontFamily
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.suspend()
            }
        }
        Text {
            visible: sddm.canReboot
            text: "󰜉"
            color: root.fg
            font.pixelSize: 22
            font.family: root.fontFamily
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.reboot()
            }
        }
        Text {
            visible: sddm.canPowerOff
            text: "󰐥"
            color: root.fg
            font.pixelSize: 22
            font.family: root.fontFamily
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.powerOff()
            }
        }
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            errorLabel.text = "Login failed — try again";
            passwordField.text = "";
            passwordField.forceActiveFocus();
        }
    }

    Component.onCompleted: passwordField.forceActiveFocus()
}
