pragma Singleton
import Quickshell

Singleton {
    property bool controlCenterOpen: false

    function toggleControlCenter() {
        controlCenterOpen = !controlCenterOpen;
    }
    function openControlCenter() {
        controlCenterOpen = true;
    }
    function closeControlCenter() {
        controlCenterOpen = false;
    }
}
