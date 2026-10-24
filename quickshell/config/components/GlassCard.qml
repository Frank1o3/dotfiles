import QtQuick
import Qt5Compat.GraphicalEffects
import qs.config

Item {
    id: root

    default property alias content: inner.data

    property int cardRadius: Appearance.radius
    property real surfaceOpacity: Appearance.glassOpacity
    property color borderColor: Qt.rgba(1, 1, 1, 0.22)
    property real borderWidth: 1

    property int shadowRadius: Appearance.shadowRadiusMedium
    property int shadowOffset: Appearance.shadowOffsetMedium
    property bool showHighlight: true
    property bool showTint: true

    property int topLeftRadius: cardRadius
    property int topRightRadius: cardRadius
    property int bottomLeftRadius: cardRadius
    property int bottomRightRadius: cardRadius

    // Subtle soft shadow - floating glass feel without heavy dark halos
    Rectangle {
        id: shadowSource
        anchors.fill: parent
        topLeftRadius: root.topLeftRadius
        topRightRadius: root.topRightRadius
        bottomLeftRadius: root.bottomLeftRadius
        bottomRightRadius: root.bottomRightRadius
        color: "black"
        visible: false
    }

    DropShadow {
        anchors.fill: shadowSource
        source: shadowSource
        radius: root.shadowRadius
        samples: root.shadowRadius * 2 + 1
        verticalOffset: root.shadowOffset
        color: Appearance.shadowColorAmbient
    }

    // Base dark backing at dynamic opacity to ensure text legibility while letting blur bleed through
    Rectangle {
        id: bgDarkBacking
        anchors.fill: parent
        color: "#0c0d16"
        opacity: root.surfaceOpacity

        topLeftRadius: root.topLeftRadius
        topRightRadius: root.topRightRadius
        bottomLeftRadius: root.bottomLeftRadius
        bottomRightRadius: root.bottomRightRadius
    }

    // Frosted glass surface sheen
    Rectangle {
        id: bgSheen
        anchors.fill: parent
        color: Qt.rgba(1, 1, 1, 0.05)

        topLeftRadius: root.topLeftRadius
        topRightRadius: root.topRightRadius
        bottomLeftRadius: root.bottomLeftRadius
        bottomRightRadius: root.bottomRightRadius
    }

    // Outer border (specular light edge)
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: root.borderWidth
        border.color: root.borderColor

        topLeftRadius: root.topLeftRadius
        topRightRadius: root.topRightRadius
        bottomLeftRadius: root.bottomLeftRadius
        bottomRightRadius: root.bottomRightRadius
    }

    // Faint accent wash from wallpaper palette for subtle depth
    Rectangle {
        visible: root.showTint
        anchors.fill: parent
        color: Colors.color(4)
        opacity: Appearance.glassTintOpacity

        topLeftRadius: root.topLeftRadius
        topRightRadius: root.topRightRadius
        bottomLeftRadius: root.bottomLeftRadius
        bottomRightRadius: root.bottomRightRadius
    }

    // Top-edge specular highlight streak (light catching glass curvature)
    Rectangle {
        visible: root.showHighlight
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: root.borderWidth
        height: Math.max(10, parent.height * Appearance.glassHighlightHeightRatio)
        topLeftRadius: Math.max(0, root.topLeftRadius - root.borderWidth)
        topRightRadius: Math.max(0, root.topRightRadius - root.borderWidth)

        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, Appearance.glassHighlightOpacity) }
            GradientStop { position: 0.35; color: Qt.rgba(1, 1, 1, Appearance.glassHighlightOpacity * 0.35) }
            GradientStop { position: 1.0; color: Qt.rgba(1, 1, 1, 0.0) }
        }
    }

    // Top rim specular bead (sharp crisp 1px light catch on upper glass edge)
    Rectangle {
        visible: root.showHighlight
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: root.borderWidth
        height: 1
        topLeftRadius: Math.max(0, root.topLeftRadius - root.borderWidth)
        topRightRadius: Math.max(0, root.topRightRadius - root.borderWidth)
        color: Qt.rgba(1, 1, 1, 0.60)
    }

    // Subtle inner border for extra edge definition on top of the glass
    Rectangle {
        anchors.fill: parent
        anchors.margins: root.borderWidth
        color: "transparent"
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, Appearance.glassInnerBorderOpacity)

        topLeftRadius: Math.max(0, root.topLeftRadius - root.borderWidth)
        topRightRadius: Math.max(0, root.topRightRadius - root.borderWidth)
        bottomLeftRadius: Math.max(0, root.bottomLeftRadius - root.borderWidth)
        bottomRightRadius: Math.max(0, root.bottomRightRadius - root.borderWidth)
    }

    Item {
        id: inner
        anchors.fill: parent
    }
}
