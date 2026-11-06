pragma Singleton
import Quickshell
import qs.services

// Shared visual tokens and Game Mode-aware motion settings.
Singleton {
    // A compact desktop scale: soft corners without turning every control
    // into a mobile-style pill.
    readonly property int radius: 10
    readonly property int radiusMedium: 8
    readonly property int radiusLarge: 16
    readonly property int spacing: 8
    readonly property int barHeight: 48
    readonly property int cardRadius: 12
    readonly property int cardPadding: 16
    readonly property int sectionSpacing: 14

    // Typography: Modern sans-serif for UI, Nerd Font for glyphs/code
    readonly property string fontFamily: "Inter"
    readonly property string monoFont: "JetBrainsMono Nerd Font"
    readonly property string iconFont: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 13
    readonly property int fontSizeSmall: 11
    readonly property int fontSizeLarge: 16

    readonly property real surfaceOpacity: 0.92
    readonly property real panelOpacity: 0.96

    // Keep shell motion coordinated with Hyprland and remove it in Game Mode.
    readonly property int animFast: GameMode.active ? 0 : 150
    readonly property int animNormal: GameMode.active ? 0 : 240
    readonly property int animSlow: GameMode.active ? 0 : 360

    readonly property string shadowColorAmbient: "#30000000"
    readonly property int shadowRadiusSmall: 12   // widgets, toasts, buttons
    readonly property int shadowRadiusMedium: 20  // bar, launcher, power menu
    readonly property int shadowRadiusLarge: 30   // control center dropdown

    readonly property int shadowOffsetSmall: 2
    readonly property int shadowOffsetMedium: 3
    readonly property int shadowOffsetLarge: 6

}
