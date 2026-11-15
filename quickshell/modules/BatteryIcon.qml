import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Services.UPower

Item {
    id: battery
    property int size: 28
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
        source: Quickshell.shellPath(iconDir + "100.svg")
        sourceSize.width: battery.size * 2
        sourceSize.height: battery.size * 2
        fillMode: Image.PreserveAspectFit

        layer.enabled: true
        layer.effect: MultiEffect {
            brightness: 1.0
            colorization: 1.0
            colorizationColor: hover2.hovered ? Colors.bg2 : Colors.selection
            Behavior on colorizationColor { ColorAnimation { duration: 150 } }
        }

        
    }

    // percentage on top; a sibling of the Image, so the tint doesn't touch it
    Text {
        anchors.centerIn: parent
        z: 1
        anchors.verticalCenterOffset: 0.5
        anchors.horizontalCenterOffset: -1
        //text: Math.round(battery.pct)
        text: "100"
        color: hover2.hovered ? Colors.selection : Colors.bg2
        Behavior on color { ColorAnimation { duration: 150 } }
        font.pixelSize: Math.round(battery.size * 0.39)
        font.bold: true
        font.family: "Inter"
    }
}