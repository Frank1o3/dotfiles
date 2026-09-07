pragma Singleton
import Quickshell

// Static design tokens — not wallust-generated, hand-tuned.
// Mirrors the "glass" look from your current waybar/style.css.
Singleton {
    readonly property int radius: 16
    readonly property int spacing: 6
    readonly property int barHeight: 45
    readonly property int cardRadius: 14
    readonly property int cardPadding: 14
    readonly property int sectionSpacing: 18

    readonly property string fontFamily: "SpaceMono Nerd Font"
    readonly property int fontSize: 12

    readonly property real glassOpacity: 0.62
    readonly property real hoverOpacity: 0.22
    readonly property real panelOpacity: 0.82

    readonly property real panelSurfaceOpacity: 0.14
    readonly property real panelBorderOpacity: 0.18
    readonly property real accentStrength: 0.92

    readonly property int animFast: 150
    readonly property int animNormal: 250
}
