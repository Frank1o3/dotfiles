pragma Singleton
import Quickshell

Singleton {
    // Per-monitor control-center state: keyed by screen name.
    property var _openScreens: ({})
    property string targetPage: "home"

    function isOpen(screenName) {
        return !!_openScreens[screenName];
    }

    function setOpen(screenName, open, page) {
        let copy = Object.assign({}, _openScreens);
        if (open) {
            copy[screenName] = true;
            if (page) targetPage = page;
        } else {
            delete copy[screenName];
        }
        _openScreens = copy;
    }

    function toggle(screenName, page) {
        if (isOpen(screenName)) {
            if (page && targetPage !== page) {
                targetPage = page;
            } else {
                setOpen(screenName, false);
            }
        } else {
            setOpen(screenName, true, page || "home");
        }
    }

    function openToPage(screenName, page) {
        targetPage = page || "home";
        setOpen(screenName, true, targetPage);
    }

    function closeAll() {
        _openScreens = {};
    }
}
