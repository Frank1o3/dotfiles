pragma Singleton
import Quickshell

Singleton {
    property bool wallpaperPickerMapped: false
    property bool powerMenuMapped: false
    property bool cheatsheetMapped: false
    property bool polkitMapped: false

    readonly property bool barHidden: wallpaperPickerMapped || powerMenuMapped || cheatsheetMapped || polkitMapped
}
