import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Polkit
import qs.config
import qs.config.components

Scope {
    id: root

    PolkitAgent { id: agent }
    readonly property var flow: agent.flow

    PanelWindow {
        id: win
        visible: agent.isActive && root.flow !== null
        onVisibleChanged: OverlayState.polkitMapped = visible
        color: "transparent"
        exclusiveZone: 0
        WlrLayershell.namespace: "quickshell:polkit"

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        HyprlandFocusGrab {
            windows: [win]
            active: win.visible
            onCleared: root.flow?.cancelAuthenticationRequest()
        }

        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.52)
            opacity: win.visible ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: Appearance.animFast } }
        }

        GlassCard {
            id: card
            anchors.centerIn: parent
            width: Math.min(460, parent.width - 32)
            implicitHeight: form.implicitHeight + 44
            cardRadius: Appearance.radiusLarge
            surfaceOpacity: Appearance.panelOpacity
            shadowRadius: Appearance.shadowRadiusMedium
            shadowOffset: Appearance.shadowOffsetMedium
            borderColor: root.flow?.supplementaryIsError ? Colors.danger : Colors.outlineStrong
            opacity: win.visible ? 1 : 0
            scale: win.visible ? 1 : 0.96
            Behavior on opacity { NumberAnimation { duration: Appearance.animNormal; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: Appearance.animNormal; easing.type: Easing.OutCubic } }

            MouseArea { anchors.fill: parent }

            ColumnLayout {
                id: form
                anchors.fill: parent
                anchors.margins: 22
                spacing: 12

                Text {
                    text: "Authentication required"
                    color: Colors.foreground
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSizeLarge + 2
                    font.weight: Font.Bold
                }

                Text {
                    Layout.fillWidth: true
                    text: root.flow?.message ?? root.flow?.actionId ?? "A privileged action needs your password."
                    color: Colors.textMuted
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSize
                    wrapMode: Text.Wrap
                }

                TextField {
                    id: passwordInput
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    focus: win.visible
                    verticalAlignment: TextInput.AlignVCenter
                    leftPadding: 12
                    rightPadding: 12
                    color: Colors.foreground
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSize
                    echoMode: root.flow?.responseVisible ? TextInput.Normal : TextInput.Password
                    passwordCharacter: "●"
                    clip: true
                    placeholderText: root.flow?.inputPrompt || "Password"
                    onAccepted: root.submit()
                    Keys.onEscapePressed: root.flow?.cancelAuthenticationRequest()
                    background: Rectangle {
                        radius: 11
                        color: Colors.surfaceRaised
                        border.width: 1
                        border.color: root.flow?.supplementaryIsError ? Colors.danger : (passwordInput.activeFocus ? Colors.accentOutline : Colors.outline)
                    }
                }

                Text {
                    Layout.fillWidth: true
                    visible: text.length > 0
                    text: root.flow?.supplementaryMessage ?? ""
                    color: root.flow?.supplementaryIsError ? Colors.danger : Colors.textMuted
                    font.family: Appearance.fontFamily
                    font.pixelSize: Appearance.fontSizeSmall
                    wrapMode: Text.Wrap
                }

                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: 8
                    GlassButton {
                        text: "Cancel"
                        onClicked: root.flow?.cancelAuthenticationRequest()
                    }
                    GlassButton {
                        text: "Authenticate"
                        icon: "✓"
                        accent: true
                        onClicked: root.submit()
                    }
                }
            }
        }
    }

    function submit() {
        if (!root.flow)
            return;
        root.flow.submit(passwordInput.text);
        passwordInput.text = "";
    }
}
