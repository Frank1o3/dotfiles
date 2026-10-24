import QtQuick
import qs.config

Row {
    id: root
    property string icon: ""
    property string text: ""
    spacing: 8

    Text {
        visible: root.icon.length > 0
        text: root.icon
        color: Colors.color(4)
        font.family: Appearance.iconFont
        font.pixelSize: 13
    }
    Text {
        text: root.text
        color: Colors.color(7)
        font.family: Appearance.fontFamily
        font.pixelSize: 11
        font.weight: Font.DemiBold
        font.capitalization: Font.AllUppercase
        font.letterSpacing: 0.8
        opacity: 0.85
    }
}
