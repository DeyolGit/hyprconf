import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Services.UPower
import QtQuick.Effects


Item {
  visible: hover && !launcher && !powermenu && !expanded
  z: 10
  anchors.fill: parent
    SystemClock {
        id: sysClock
        precision: SystemClock.Minutes
    }
   RowLayout {
    anchors.fill: parent
    anchors.margins: 15

    MediaWidget {}

    Item { Layout.fillWidth: true }

    // your clock in the middle, wifi/battery on the right  
}

 Text {
          id: clockText
          property string time: Qt.formatDateTime(new Date(), "HH:mm")
          anchors.top: parent.top
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.topMargin: 15
          text: time
          color: Colors.fg
          font { family: root.fontFamily; pixelSize: 22; bold: false }
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: clock.time = Qt.formatDateTime(new Date(), "HH:mm")
    }
        }

 Text {
    id: dateText
    anchors.top: clockText.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.topMargin: 4
    text: Qt.formatDateTime(sysClock.date, "ddd, d MMM")
    color: "#A9A9A9"
    font { family: root.fontFamily; pixelSize: 11; bold: false }
    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: dateText.text = Qt.formatDateTime(new Date(), "ddd, d MMM")
      }
 
    }

   Rectangle {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        property bool controlHover: false
        width: 65
        height: 30
        color: Colors.bg3
        border.width: 1
        radius: 10
        border.color: Colors.bg4
        anchors.rightMargin: 20
        
        MouseArea {
          anchors.fill: parent
          onClicked: root.expanded = !root.expanded
          cursorShape: Qt.PointingHandCursor
        }
        Image {
          id: wifi
          z: 10
          anchors.left: parent.left
          anchors.leftMargin: 3
          anchors.bottom: parent.bottom
          anchors.bottomMargin: 5
          source: "file:///home/mihailo/.config/quickshell/icons/wifi.svg"
          sourceSize.width: 26
          sourceSize.height: 26
          fillMode: Image.PreserveAspectFit
          layer.enabled: true
          layer.effect: MultiEffect {
              brightness: 1.0
              colorization: 1.0
              colorizationColor: Colors.green
            }
        }


        BatteryIcon {
          anchors.right: parent.right
          anchors.rightMargin: 7
          anchors.verticalCenter: parent.verticalCenter
        }


    }
  
}
