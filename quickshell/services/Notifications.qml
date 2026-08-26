pragma Singleton
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    property bool dnd: false
    readonly property var list: server.trackedNotifications
    readonly property int count: list ? list.values.length : 0

    signal popup(var notification)

    NotificationServer {
        id: server
        keepOnReload: true
        actionsSupported: true
        actionIconsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true

        onNotification: notification => {
            notification.tracked = true;
            if (!root.dnd) {
                root.popup(notification);
            }
        }
    }

    function dismiss(notification) {
        notification.dismiss();
    }

    function clearAll() {
        const items = server.trackedNotifications.values.slice();
        items.forEach(n => n.dismiss());
    }

    function toggleDnd() {
        root.dnd = !root.dnd;
    }
}
