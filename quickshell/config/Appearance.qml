pragma Singleton
import Quickshell

// Static design tokens — not wallust-generated, hand-tuned.
// Mirrors the "glass" look from your current waybar/style.css.
Singleton {
    readonly property int radius: 16
    readonly property int spacing: 6
    readonly property int barHeight: 45

    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 12

    readonly property real glassOpacity: 0.55
    readonly property real hoverOpacity: 0.18

    readonly property int animFast: 150
    readonly property int animNormal: 250
}
