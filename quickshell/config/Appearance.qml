pragma Singleton
import Quickshell

// Static design tokens for Fluid Glass
Singleton {
    readonly property int radius: 16
    readonly property int radiusLarge: 22
    readonly property int spacing: 6
    readonly property int barHeight: 45
    readonly property int cardRadius: 14
    readonly property int cardPadding: 14
    readonly property int sectionSpacing: 18

    readonly property string fontFamily: "SpaceMono Nerd Font"
    readonly property int fontSize: 12

    readonly property real glassOpacity: 0.22
    readonly property real hoverOpacity: 0.18
    readonly property real panelOpacity: 0.82

    readonly property real panelSurfaceOpacity: 0.12
    readonly property real panelBorderOpacity: 0.22
    readonly property real accentStrength: 0.92

    readonly property int animFast: 150
    readonly property int animNormal: 250

    // ---------------------------------------------------------------
    // Glass depth tokens
    // ---------------------------------------------------------------
    // Soft, airy ambient shadow that floats above blurred wallpaper
    readonly property string shadowColorAmbient: "#22000000"
    readonly property string shadowColorContact: "#38000000"

    readonly property int shadowRadiusSmall: 18   // widgets, toasts, buttons
    readonly property int shadowRadiusMedium: 24  // bar pill, launcher, power menu
    readonly property int shadowRadiusLarge: 36   // control center dropdown

    readonly property int shadowOffsetSmall: 2
    readonly property int shadowOffsetMedium: 4
    readonly property int shadowOffsetLarge: 8

    // Specular top highlight streak
    readonly property real glassHighlightOpacity: 0.32
    readonly property real glassHighlightHeightRatio: 0.45

    // Faint accent-tinted layer
    readonly property real glassTintOpacity: 0.04

    readonly property real glassInnerBorderOpacity: 0.14
}
