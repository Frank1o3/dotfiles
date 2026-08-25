import QtQuick
import Quickshell.Services.UPower
import qs.config

Text {
    id: root
    readonly property UPowerDevice bat: UPower.displayDevice
    readonly property int percent: Math.round((bat?.percentage ?? 0) * 100)
    readonly property bool charging: bat?.state === UPowerDeviceState.Charging

    visible: bat?.isLaptopBattery ?? false
    color: Colors.color(8)
    font.family: Appearance.fontFamily
    font.pixelSize: Appearance.fontSize
    text: (charging ? "󰂄 " : "󰁹 ") + percent + "%"
}
