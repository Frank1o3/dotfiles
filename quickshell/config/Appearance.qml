pragma Singleton
import Quickshell

// Static design tokens for Fluid Glass
Singleton {
    readonly property int radius: 16
    readonly property int radiusLarge: 22
    readonly property int spacing: 8
    readonly property int barHeight: 44
    readonly property int cardRadius: 16
    readonly property int cardPadding: 16
    readonly property int sectionSpacing: 18

    // Typography: Modern sans-serif for UI, Nerd Font for glyphs/code
    readonly property string fontFamily: "Inter"
    readonly property string monoFont: "JetBrainsMono Nerd Font"
    readonly property string iconFont: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 13
    readonly property int fontSizeSmall: 11
    readonly property int fontSizeLarge: 16

    readonly property real glassOpacity: 0.20
    readonly property real hoverOpacity: 0.15
    readonly property real panelOpacity: 0.72

    readonly property real panelSurfaceOpacity: 0.15
    readonly property real panelBorderOpacity: 0.20
    readonly property real accentStrength: 0.92

    readonly property int animFast: 160
    readonly property int animNormal: 260
    readonly property int animSlow: 380

    // ---------------------------------------------------------------
    // Glass depth tokens
    // ---------------------------------------------------------------
    // Soft, airy ambient shadow that floats above blurred wallpaper
    readonly property string shadowColorAmbient: "#22000000"
    readonly property string shadowColorContact: "#38000000"

    readonly property int shadowRadiusSmall: 16   // widgets, toasts, buttons
    readonly property int shadowRadiusMedium: 24  // bar pill, launcher, power menu
    readonly property int shadowRadiusLarge: 36   // control center dropdown

    readonly property int shadowOffsetSmall: 2
    readonly property int shadowOffsetMedium: 4
    readonly property int shadowOffsetLarge: 8

    // Specular top highlight streak
    readonly property real glassHighlightOpacity: 0.35
    readonly property real glassHighlightHeightRatio: 0.40

    // Faint accent-tinted layer
    readonly property real glassTintOpacity: 0.05

    readonly property real glassInnerBorderOpacity: 0.16
}
