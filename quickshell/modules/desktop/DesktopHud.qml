import Quickshell
import Quickshell.Io
import qs.config

Scope {
    IpcHandler {
        target: "widgets"
        function edit(): void { UserSettings.layoutEditMode = !UserSettings.layoutEditMode; }
        function reset(): void {
            UserSettings.hudPositionsJson = "{}";
            UserSettings.layoutJson = "{}";
        }
    }

    Variants {
        model: Quickshell.screens
        HudWidgetWindow { required property var modelData; screenData: modelData; widgetKey: "clock"; defaultX: 0.82; defaultY: 0.05 }
    }
    Variants {
        model: Quickshell.screens
        HudWidgetWindow { required property var modelData; screenData: modelData; widgetKey: "stats"; defaultX: 0.86; defaultY: 0.28 }
    }
    Variants {
        model: Quickshell.screens
        HudWidgetWindow { required property var modelData; screenData: modelData; widgetKey: "launcher"; defaultX: 0.02; defaultY: 0.29 }
    }
}
