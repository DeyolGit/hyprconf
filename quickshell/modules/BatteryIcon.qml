import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Services.UPower

Item {
    id: battery
    property int size: 24
    property color tint: "#cdd6f4"

    readonly property string iconDir: "icons/battery/"
    readonly property var dev: UPower.displayDevice
    readonly property real pct: dev.percentage * 100   // Quickshell gives 0..1
    readonly property bool charging: dev.state === UPowerDeviceState.Charging

    // nearest icon to the current level (midpoints between 100/70/50/35/20/10)
    readonly property int level: pct >= 85 ? 100
                               : pct >= 60 ? 70
                               : pct >= 42 ? 50
                               : pct >= 27 ? 35
                               : pct >= 15 ? 20
                               : 10

    implicitWidth: size
    implicitHeight: size

    Image {
        anchors.fill: parent
        source: Quickshell.shellPath(battery.iconDir + battery.level + ".svg")
        sourceSize.width: battery.size * 2
        sourceSize.height: battery.size * 2
        fillMode: Image.PreserveAspectFit

        layer.enabled: true
        layer.effect: MultiEffect {
            brightness: 1.0
            colorization: 1.0
            colorizationColor: battery.charging ? Colors.green
                             : battery.level <= 20 ? Colors.green
                             : battery.tint
        }

    }

    
}