import QtQuick
import Qt5Compat.GraphicalEffects
import qs.config
import qs.services

Item {
    id: root

    default property alias content: inner.data

    property int cardRadius: Appearance.radius
    property real surfaceOpacity: Appearance.surfaceOpacity
    property color borderColor: Colors.outline
    property real borderWidth: 1
    property int shadowRadius: Appearance.shadowRadiusMedium
    property int shadowOffset: Appearance.shadowOffsetMedium

    property int topLeftRadius: cardRadius
    property int topRightRadius: cardRadius
    property int bottomLeftRadius: cardRadius
    property int bottomRightRadius: cardRadius

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
        visible: !GameMode.active
    }

    // One palette-derived surface and one quiet outline keep cards coherent.
    Rectangle {
        anchors.fill: parent
        topLeftRadius: root.topLeftRadius
        topRightRadius: root.topRightRadius
        bottomLeftRadius: root.bottomLeftRadius
        bottomRightRadius: root.bottomRightRadius
        color: Colors.surface
        opacity: GameMode.active ? 1 : root.surfaceOpacity
        border.width: root.borderWidth
        border.color: root.borderColor
    }

    Item {
        id: inner
        anchors.fill: parent
    }
}
