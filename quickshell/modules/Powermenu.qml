import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Bluetooth
import QtQuick.Controls
import Quickshell.Widgets

Item {
  id: powerMenu
  anchors.fill: parent
  clip: true
  z: 10
  visible: root.powermenu && !root.launcher && !root.expanded

  // set this to your nerd font if the icons show up as boxes
  property string iconFont: "Symbols Nerd Font"

  property var actions: [
    { label: "Shutdown", icon: "\uf011", cmd: ["systemctl", "poweroff"] },
    { label: "Reboot",   icon: "\uf021", cmd: ["systemctl", "reboot"] },
     { label: "Suspend",  icon: "\uf186", cmd: ["systemctl", "suspend"] },
    { label: "Lock",     icon: "\uf023", cmd: ["hyprlock"] },
    { label: "Logout",   icon: "\uf08b", cmd: ["hyprctl", "dispatch", "exit"] },
       { label: "Cancel",   icon: "\uf05e", cmd: [] }
  ]

  function run(a) {
    root.powermenu = false
    if (a.cmd.length > 0) Quickshell.execDetached(a.cmd)
  }

  function move(d) {
    const n = actions.length
    list.currentIndex = (list.currentIndex + d + n) % n
  }

  onVisibleChanged: if (visible) {
    list.currentIndex = 0
    focusTimer.restart()
  }

  Timer {
    id: focusTimer
    interval: 50
    onTriggered: keys.forceActiveFocus()
  }

  Rectangle {
    anchors.fill: parent
    radius: 16
    color: Colors.bg0

    // takes the keyboard input
    Item {
      id: keys
      anchors.fill: parent
      focus: true

      Keys.onPressed: event => {
        const ctrl = event.modifiers & Qt.ControlModifier
        if (event.key === Qt.Key_Escape) {
          root.powermenu = false
        } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab
                   || event.key === Qt.Key_J
                   || (ctrl && event.key === Qt.Key_N)) {
          powerMenu.move(1)
        } else if (event.key === Qt.Key_Up || event.key === Qt.Key_Backtab
                   || event.key === Qt.Key_K
                   || (ctrl && event.key === Qt.Key_P)) {
          powerMenu.move(-1)
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
          powerMenu.run(powerMenu.actions[list.currentIndex])
        } else {
          return
        }
        event.accepted = true
      }
    }

    ListView {
      id: list
      anchors.fill: parent
      anchors.margins: 10
      spacing: 4
      interactive: false
      model: powerMenu.actions
      currentIndex: 0
      highlightMoveDuration: 0

      delegate: Rectangle {
        id: row
        required property var modelData
        required property int index

        width: list.width
        height: 28
        radius: 8
        color: ListView.isCurrentItem ? Colors.green : "transparent"

        Text {
          id: ico
          anchors.left: parent.left
          anchors.leftMargin: 8
          anchors.verticalCenter: parent.verticalCenter
          width: 16
          horizontalAlignment: Text.AlignHCenter
          text: row.modelData.icon
          font.family: powerMenu.iconFont
          font.pixelSize: 14
          color: row.ListView.isCurrentItem ? "#2d353b" : "#d3c6aa"
        }

        Text {
          anchors.left: ico.right
          anchors.leftMargin: 2
          anchors.verticalCenter: parent.verticalCenter
          text: row.modelData.label
          font.pixelSize: 14
          color: row.ListView.isCurrentItem ? "#2d353b" : "#d3c6aa"
        }

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          onPositionChanged: list.currentIndex = row.index
          onClicked: powerMenu.run(row.modelData)
        }
      }
    }
  }

}
