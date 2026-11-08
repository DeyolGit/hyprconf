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
import Quickshell.Services.UPower

PanelWindow {
  id: root
  color: "transparent"
  implicitWidth: 500
  implicitHeight: 400
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Top
     WlrLayershell.keyboardFocus: (root.launcher || root.powermenu || root.expanded) ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
  
   surfaceFormat.opaque: false
  //EXPANDED
  property bool expanded: false
  property bool launcher: false
  property bool powermenu: false
  property bool hover: false

    anchors {
      top: true
      
      
    }
    
    margins {
        top: 7
      }
     
      
  mask: Region {
        item: pill
    } 
     
      

    Shortcut {
    sequence: "Escape"
    onActivated: root.expanded = false,launcher = false, powermenu = false
    }
    
    property string fontFamily: "Inter"
    property int fontSize: 15
    



    
   GlobalShortcut {
    name: "controlCenter"
    
    onPressed: {
      expanded = !expanded
      launcher = false
      powermenu = false
    }
} 

GlobalShortcut {
    name: "appLauncher"
    
    onPressed: {
      launcher = !launcher
      powermenu = false
      expanded = false
    }
  }

GlobalShortcut {
    name: "powermenu"
    
    onPressed: {
      launcher = false
      expanded = false
      powermenu = !powermenu
    }
  }

      
    
   
    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: clock.time = Qt.formatDateTime(
            new Date(), "HH:mm"
        )
      }
      //NOT expanded
      
    Rectangle {

      id: pill
       width: hover ? 470: powermenu ? 250: launcher ? 480: expanded ? 500:130
       height: hover ? 80: powermenu ? 210: launcher ? 245: expanded ? 386:36 
      

        

       Behavior on width {
         NumberAnimation {
           duration: 200
           easing.type: Easing.OutCubic
         } 
       } 
       Behavior on height {
         NumberAnimation {
           duration: 300
           easing.type: Easing.OutCubic
         } 
       }  
      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        enabled: !launcher && !expanded && !powermenu
        onEntered: hover = true
        onExited: hover = false
      }
      radius: 20
      anchors {
        top: parent.top
        horizontalCenter: parent.horizontalCenter 
        topMargin: 0
       }
      
        clip: true
        
        color: Colors.bg0

       //HOVERED 
       Hover {}

        //EXPANDED

      Expanded {}

      //APP launcher
      AppLauncher {}

      //Powermenu 
      Powermenu {}
    Item {
      anchors.horizontalCenter: parent.horizontalCenter 
      visible: !launcher && !expanded && !powermenu && !hover 
      anchors.fill: parent
    
        RowLayout {
           anchors.centerIn: parent
           anchors.leftMargin: 30
           spacing: 5

          PlayingBars {

            id: bars
            anchors.right: clock.left
            anchors.rightMargin: 8
            anchors.verticalCenter: clock.verticalCenter
          }

        
        Text {
          id: clock
          property string time: Qt.formatDateTime(new Date(), "HH:mm")
          text: time
          color: Colors.fg
          font { family: root.fontFamily; pixelSize: root.fontSize; bold: false }
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          anchors.verticalCenter: parent.verticalCenter
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.horizontalCenterOffset: bars.playing ? (bars.implicitWidth + 8) / 2 : 0

          Behavior on anchors.horizontalCenterOffset {
              NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }
      


          //Right
        } 
        }
        
  
}
}

}


   

