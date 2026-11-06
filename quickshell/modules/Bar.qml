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
    // Theme
    property color colBg: "#2d353b"
    property color colFg: "#a9b1d6"
    property color colWhite: "#ffffff"
    property color colMuted: "#444b6a"
    property color colCyan: "#0db9d7"
    property color colBlue: "#a6bf80"
    property color colYellow: "#e0af68"
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
       width: powermenu ? 250: launcher ? 480: expanded ? 500:180
       height: powermenu ? 210: launcher ? 245: expanded ? 386:35  
       
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

      radius: 20
      border.width: 1
      border.color: "#03030303"
      anchors {
        top: parent.top
        horizontalCenter: parent.horizontalCenter 
        topMargin: 0
    }
      
        clip: true
        
        color: root.colBg 
        
        //EXPANDED

      Expanded {}

      //APP launcher
      AppLauncher {}

      //Powermenu 
      Powermenu {}
    Item {
      anchors.horizontalCenter: parent.horizontalCenter 
      visible: !launcher && !expanded && !powermenu 
      anchors.fill: parent
    RowLayout {
        
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8
        Process {
             id: swaync
              command: ["swaync-client", "-t", "-sw"]
          }       
        //Left
      Item {
            Layout.preferredWidth: 100
            Layout.fillHeight: true
        Row {
          spacing: 6
          height: 18 
          anchors.centerIn: parent
          transform: Translate {
             x: -22 
             y: -3
          }

            Repeater {
               model: [1, 2, 3, 4]
                
               Rectangle {
                 
                    required property var modelData
                    width: 8
                    height: Hyprland.focusedWorkspace?.id === modelData ? 18 : 8
                    y: (18 - height) / 2
                    radius: 4

                    color: Hyprland.focusedWorkspace?.id === modelData
                        ? "#a6bf80"
                        : "#585b70"

                      Behavior on height {
                           NumberAnimation {
                              duration: 150
                           }
                       }

                       MouseArea {
                             anchors.fill: parent
                             cursorShape: Qt.PointingHandCursor

                         onClicked: {
                             Hyprland.dispatch(
                                  "hl.dsp.focus({ workspace = " + modelData + " })"
                                )
                           }
                         }
                 }
             }
           }
    } 
        // Center
        Text {
          id: clock
          property string time: Qt.formatDateTime(new Date(), "HH:mm")
          anchors.centerIn: parent
          text: time
          color: root.colWhite
          font { family: root.fontFamily; pixelSize: root.fontSize; bold: false }
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
  
  
          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor

            onClicked: {
               expanded = !expanded 
            }
          }


          //Right
        }
        Text {
          id: bluetoothButton
          transform: Translate {
             x: -8 
             y: -2
          }
          property var adapter: Bluetooth.defaultAdapter
          anchors.centerIn: parent.Left
          text: "󰂯"
           color: adapter && adapter.enabled ? "#a6bf80" : "#6c7086"
          font { family: root.fontFamily; pixelSize: 17; bold: false }
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
         MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (bluetoothButton.adapter)
                bluetoothButton.adapter.enabled =
                !bluetoothButton.adapter.enabled

          }
        }


        Text {
          id: networkButton
          transform: Translate {
            x: -28
            y: 1
          }
          
          anchors.centerIn: parent.Left
          text: " "
           color: "#a6bf80"
          font { family: root.fontFamily; pixelSize: 14; bold: false }
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
         MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: {
           Quickshell.execDetached("nm-connection-editor") 

          }
        }


              
         


      }
    }
  }
}
}

}


   

