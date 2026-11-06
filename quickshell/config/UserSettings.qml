pragma Singleton
import Qt.labs.settings
import Quickshell

Singleton {
    id: root
    property string hudPositionsJson: "{}"
    property bool dnd: false
    property string barMode: "physical"
    property string launcherMode: "widget"
    property bool layoutEditMode: false
    property string layoutJson: "{}"

    Settings {
        fileName: `${Quickshell.env("HOME")}/.config/quickshell/settings.ini`
        category: "Desktop"
        property alias hudPositionsJson: root.hudPositionsJson
        property alias dnd: root.dnd
        property alias barMode: root.barMode
        property alias launcherMode: root.launcherMode
        property alias layoutJson: root.layoutJson
    }

    function position(widgetId, fallbackX, fallbackY) {
        let positions = {};
        try { positions = JSON.parse(hudPositionsJson || "{}"); } catch (e) {}
        return positions[widgetId] || { x: fallbackX, y: fallbackY };
    }

    function savePosition(widgetId, x, y) {
        let positions = {};
        try { positions = JSON.parse(hudPositionsJson || "{}"); } catch (e) {}
        positions[widgetId] = { x: Math.max(0, Math.min(1, x)), y: Math.max(0, Math.min(1, y)) };
        hudPositionsJson = JSON.stringify(positions);
    }

    function layout(widgetId, fallback) {
        let layouts = {};
        try { layouts = JSON.parse(layoutJson || "{}"); } catch (e) {}
        return layouts[widgetId] || fallback;
    }

    function setLayout(widgetId, value) {
        let layouts = {};
        try { layouts = JSON.parse(layoutJson || "{}"); } catch (e) {}
        layouts[widgetId] = value;
        layoutJson = JSON.stringify(layouts);
    }
}
