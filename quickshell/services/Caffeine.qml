pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    property bool active: false

    function toggle(): void {
        root.active = !root.active;
    }
}
