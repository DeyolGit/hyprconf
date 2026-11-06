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
  id: appLauncher
  anchors.fill: parent
  z: 10
  clip: true
  visible: root.launcher && !root.expanded && !root.powermenu

  onVisibleChanged: if (visible) {
    field.text = ""
    list.currentIndex = 0
    field.forceActiveFocus()
  }

   // apps listed here come first, in this order (match the name shown in the launcher, case doesn't matter)
  property var pinned: [
    "freesm launcher",
    "visual studio code",
    "discord",
    "localsend",
    "cyberpunk 2077",
    "stremio"
  ]

  function rank(a) {
    const n = a.name.toLowerCase()
    const id = (a.id || "").toLowerCase()
    const i = pinned.findIndex(p => p === n || p === id || p + ".desktop" === id)
    return i === -1 ? 9999 : i
  }

  property var results: {
    const q = field.text.trim().toLowerCase()
    const apps = DesktopEntries.applications.values.filter(a => !a.noDisplay)
    const byPin = (a, b) => rank(a) - rank(b) || a.name.localeCompare(b.name)
    if (q === "")
      return apps.slice().sort(byPin)
    return apps
      .map(a => ({ app: a, n: a.name.toLowerCase() }))
      .filter(x => x.n.includes(q))
      .sort((x, y) => {
        const sx = x.n.startsWith(q) ? 0 : 1
        const sy = y.n.startsWith(q) ? 0 : 1
        return sx !== sy ? sx - sy : byPin(x.app, y.app)
      })
      .map(x => x.app)
  } 
  
    function iconSrc(e) {
    const i = e.icon || ""
    if (i.startsWith("/")) return "file://" + i
    return Quickshell.iconPath(i, "application-x-executable")
  }

  function launch() {
    const e = results[list.currentIndex]
    if (!e) return
    e.execute()
    root.launcher = false
  }

  function move(d) {
    const n = results.length
    if (n === 0) return
    list.currentIndex = (list.currentIndex + d + n) % n
  }

  Rectangle {
    anchors.fill: parent
    radius: 16
    color: "#2d353b"

    // search box
    Rectangle {
      id: searchBox
      anchors { top: parent.top; left: parent.left; right: parent.right; margins: 10 }
      height: 30
      radius: 8
      color: "#272e33"

      TextInput {
        id: field
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        verticalAlignment: TextInput.AlignVCenter
        color: "#d3c6aa"
        selectionColor: "#a7c080"
        selectedTextColor: "#2d353b"
        font.pixelSize: 14
        clip: true

        onTextChanged: list.currentIndex = 0

        Keys.onPressed: event => {
          const ctrl = event.modifiers & Qt.ControlModifier
          if (event.key === Qt.Key_Escape) {
            root.launcher = false
          } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab
                     || (ctrl && (event.key === Qt.Key_J || event.key === Qt.Key_N))) {
            appLauncher.move(1)
          } else if (event.key === Qt.Key_Up || event.key === Qt.Key_Backtab
                     || (ctrl && (event.key === Qt.Key_K || event.key === Qt.Key_P))) {
            appLauncher.move(-1)
          } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            appLauncher.launch()
          } else {
            return
          }
          event.accepted = true
        }

        Text {
          anchors.verticalCenter: parent.verticalCenter
          visible: field.text === ""
          text: "Search..."
          color: "#859289"
          font.pixelSize: 14
        }
      }
    }
    

    // app list
    ListView {
      id: list
      anchors {
        top: searchBox.bottom; topMargin: 6
        left: parent.left; right: parent.right; bottom: parent.bottom
        leftMargin: 10; rightMargin: 10; bottomMargin: 10
      }
      spacing: 4
      clip: true
      model: appLauncher.results
      currentIndex: 0
      highlightMoveDuration: 0
      boundsBehavior: Flickable.StopAtBounds
      onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

      delegate: Rectangle {
        id: row
        required property var modelData
        required property int index

        width: list.width
        height: 28
        radius: 8
        color: ListView.isCurrentItem ? "#a7c080" : "transparent"

         Image {
          id: icon
          anchors.left: parent.left
          anchors.leftMargin: 8
          anchors.verticalCenter: parent.verticalCenter
          width: 20
          height: 20
          sourceSize: Qt.size(40, 40)
          fillMode: Image.PreserveAspectFit
          asynchronous: true
          source: appLauncher.iconSrc(row.modelData)
        } 
        Text {
          anchors.left: icon.right
          anchors.leftMargin: 10
          anchors.right: parent.right
          anchors.rightMargin: 8
          anchors.verticalCenter: parent.verticalCenter
          text: row.modelData.name
          elide: Text.ElideRight
          font.pixelSize: 14
          color: row.ListView.isCurrentItem ? "#2d353b" : "#d3c6aa"
        }

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          onPositionChanged: list.currentIndex = row.index
          onClicked: {
            list.currentIndex = row.index
            appLauncher.launch()
          }
        }
      }
    }
  }


}
