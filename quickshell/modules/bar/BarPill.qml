import QtQuick
import QtQuick.Layouts
import qs.config
import qs.config.components

Item {
    id: root

    default property alias content: row.data
    property bool hovered: mouse.containsMouse

    implicitWidth: row.implicitWidth + Appearance.spacing * 4
    implicitHeight: Appearance.barHeight - 12

    GlassCard {
        anchors.fill: parent
        cardRadius: Math.round(root.height / 2)
        surfaceOpacity: root.hovered ? Math.min(0.95, Appearance.glassOpacity + 0.12) : Appearance.glassOpacity
        borderColor: root.hovered ? Qt.rgba(1, 1, 1, 0.35) : Qt.rgba(1, 1, 1, 0.18)
        borderWidth: 1
        shadowRadius: Appearance.shadowRadiusSmall
        shadowOffset: Appearance.shadowOffsetSmall
        showHighlight: true
        showTint: true
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 6
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton // widgets add their own click areas
    }
}
