import QtQuick
import Quickshell.Services.UPower
import qs.config

Text {
    id: root
    property bool compact: false
    readonly property UPowerDevice bat: UPower.displayDevice
    readonly property int percent: Math.round((bat?.percentage ?? 0) * 100)
    readonly property bool charging: bat?.state === UPowerDeviceState.Charging

    visible: bat?.isLaptopBattery ?? false
    color: charging ? Colors.color(4) : (percent <= 15 ? Colors.danger : (percent <= 30 ? Colors.color(3) : Colors.textMain))
    font.family: Appearance.fontFamily
    font.pixelSize: Appearance.fontSize
    font.weight: Font.Bold
    text: compact ? (charging ? "󰂄" : "󰁹") : (charging ? "󰂄 " : "󰁹 ") + percent + "%"

    Behavior on color {
        ColorAnimation {
            duration: Appearance.animFast
        }
    }
}
