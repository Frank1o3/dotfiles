import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

import qs.config.components
import qs.config

Scope {
    id: root

    property bool open: false
    property bool mapped: false
    property string armedCommand: ""
    property int selected: 0

    onMappedChanged: OverlayState.powerMenuMapped = mapped

    function show() {
        selected = 0;
        armedCommand = "";
        mapped = true;
        open = true;
        Qt.callLater(() => menuMouse.forceActiveFocus());
    }
    function hide() {
        open = false;
        closeTimer.start();
    }
    function toggle() {
        open ? hide() : show();
    }

    Timer {
        id: closeTimer
        interval: Math.max(1, Appearance.animNormal)
        onTriggered: root.mapped = false
    }

    Timer {
        id: confirmTimer
        interval: 4000
        onTriggered: root.armedCommand = ""
    }

    IpcHandler {
        target: "powermenu"
        function toggle(): void {
            root.toggle();
        }
        function open(): void {
            root.show();
        }
        function close(): void {
            root.hide();
        }
    }

    Process {
        id: notifyProc
    }
    Process {
        id: actionProc
    }

    function runAction(cmd, notifyTitle, notifyBody, confirm) {
        if (confirm && root.armedCommand !== cmd) {
            root.armedCommand = cmd;
            confirmTimer.restart();
            return;
        }
        root.armedCommand = "";
        notifyProc.command = ["notify-send", "-t", "2000", notifyTitle, notifyBody];
        notifyProc.running = true;
        actionProc.command = ["sh", "-c", cmd];
        actionProc.running = true;
        root.hide();
    }

    function activateSelected() {
        switch (selected) {
        case 0: runAction("qs ipc call lockscreen lock || hyprlock || swaylock || loginctl lock-session", "Locking", "Screen locked", false); break;
        case 1: runAction("systemctl suspend", "Sleeping", "System suspending", false); break;
        case 2: runAction("systemctl hibernate", "Hibernating", "System hibernating", true); break;
        case 3: runAction("systemctl reboot", "Rebooting", "System restarting", true); break;
        case 4: runAction("systemctl poweroff", "Shutting down", "System powering off", true); break;
        case 5: runAction("loginctl terminate-user \"$USER\"", "Signing out", "Ending Hyprland session...", true); break;
        }
    }

    PanelWindow {
        id: win
        visible: root.mapped
        color: "transparent"
        exclusiveZone: 0
        WlrLayershell.namespace: "quickshell:powermenu"

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        HyprlandFocusGrab {
            windows: [win]
            active: root.open
            onCleared: root.hide()
        }

        MouseArea {
            id: menuMouse
            anchors.fill: parent
            focus: root.open
            onClicked: root.hide()
            Keys.onPressed: event => {
                if (event.key === Qt.Key_Left || event.key === Qt.Key_Up)
                    root.selected = (root.selected + 5) % 6;
                else if (event.key === Qt.Key_Right || event.key === Qt.Key_Down)
                    root.selected = (root.selected + 1) % 6;
                else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space)
                    root.activateSelected();
                else if (event.key >= Qt.Key_1 && event.key <= Qt.Key_6) {
                    root.selected = event.key - Qt.Key_1;
                    root.activateSelected();
                } else if (event.key === Qt.Key_Escape)
                    root.hide();
                else
                    return;
                event.accepted = true;
            }

            GlassCard {
                id: card
                anchors.centerIn: parent
                width: 380
                height: 300
                cardRadius: Appearance.radiusLarge
                surfaceOpacity: Appearance.panelOpacity
                shadowRadius: Appearance.shadowRadiusMedium
                shadowOffset: Appearance.shadowOffsetMedium

                opacity: root.open ? 1 : 0
                transformOrigin: Item.Center
                scale: root.open ? 1 : 0.9

                Behavior on scale {
                    NumberAnimation {
                        duration: Appearance.animNormal
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.05
                    }
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: Appearance.animFast
                    }
                }

                MouseArea {
                    anchors.fill: parent
                } // eat clicks so the card doesn't close itself

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 16

                    Text {
                        text: "⏻  Power Menu"
                        color: Colors.foreground
                        font.family: Appearance.fontFamily
                        font.pixelSize: 18
                        font.bold: true
                        font.weight: Font.Bold
                    }

                    Text {
                        text: "Arrow keys or 1–6 choose · Enter activates · Esc closes"
                        color: Colors.color(7)
                        font.family: Appearance.fontFamily
                        font.pixelSize: Appearance.fontSizeSmall
                    }

                    GridLayout {
                        columns: 2
                        columnSpacing: 10
                        rowSpacing: 10
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        GlassButton {
                            Layout.fillWidth: true
                            icon: "󰌾"
                            text: "Lock"
                            accent: root.selected === 0
                            onClicked: { root.selected = 0; root.activateSelected() }
                        }
                        GlassButton {
                            Layout.fillWidth: true
                            icon: "󰤄"
                            text: "Sleep"
                            accent: root.selected === 1
                            onClicked: { root.selected = 1; root.activateSelected() }
                        }
                        GlassButton {
                            Layout.fillWidth: true
                            icon: "󰋊"
                            text: root.armedCommand === "systemctl hibernate" ? "Confirm hibernate" : "Hibernate"
                            accent: root.selected === 2
                            onClicked: { root.selected = 2; root.activateSelected() }
                        }
                        GlassButton {
                            Layout.fillWidth: true
                            icon: "󰜉"
                            text: root.armedCommand === "systemctl reboot" ? "Confirm reboot" : "Reboot"
                            accent: root.selected === 3
                            onClicked: { root.selected = 3; root.activateSelected() }
                        }
                        GlassButton {
                            Layout.fillWidth: true
                            icon: "󰐥"
                            accent: root.selected === 4
                            text: root.armedCommand === "systemctl poweroff" ? "Confirm shutdown" : "Shutdown"
                            onClicked: { root.selected = 4; root.activateSelected() }
                        }
                        GlassButton {
                            Layout.fillWidth: true
                            icon: "󰍃"
                            text: root.armedCommand === "loginctl terminate-user \"$USER\"" ? "Confirm sign out" : "Sign Out"
                            accent: root.selected === 5
                            onClicked: { root.selected = 5; root.activateSelected() }
                        }
                    }
                }
            }
        }
    }
}
