import QtQuick
import QtQuick.Layouts
import qs.config

Item {
    id: root

    property string icon: ""
    property string label: ""
    property string subLabel: ""
    property bool active: false
    property bool interactive: true
    signal clicked
    activeFocusOnTab: root.interactive

    Keys.onReturnPressed: if (root.interactive) root.clicked()
    Keys.onEnterPressed: if (root.interactive) root.clicked()
    Keys.onSpacePressed: if (root.interactive) root.clicked()

    implicitHeight: 50
    readonly property color accentColor: Colors.color(4)

    // Glass backdrop
    Rectangle {
        anchors.fill: parent
        radius: Appearance.cardRadius
        color: root.active
            ? Colors.accentSurface
            : (mouse.containsMouse && root.interactive) ? Colors.surfaceHover : Colors.surfaceSubtle
        border.width: 1
        border.color: root.active ? Colors.accentOutline : Colors.outline

        Behavior on color {
            ColorAnimation { duration: Appearance.animFast }
        }
        Behavior on border.color {
            ColorAnimation { duration: Appearance.animFast }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        // Squared icon tile gives dense desktop controls a clear anchor.
        Rectangle {
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            radius: Appearance.radiusMedium
            color: root.active ? root.accentColor : Colors.surfaceRaised

            Text {
                anchors.centerIn: parent
                text: root.icon
                color: root.active ? Colors.background : Colors.foreground
                font.family: Appearance.iconFont
                font.pixelSize: 15
            }
        }

        // Title and Subtitle
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: root.label
                color: root.active ? Colors.foreground : Colors.textMain
                font.family: Appearance.fontFamily
                font.pixelSize: Appearance.fontSizeSmall + 1
                font.weight: Font.DemiBold
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                visible: root.subLabel.length > 0
                text: root.subLabel
                color: root.active ? root.accentColor : Colors.color(7)
                font.family: Appearance.fontFamily
                font.pixelSize: 11
                elide: Text.ElideRight
                Layout.fillWidth: true
                opacity: 0.85
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.interactive
        cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }
}
