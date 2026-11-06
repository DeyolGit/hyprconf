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
       Process {
    id: volumeSetter
    command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", controlCenter.volume.toFixed(2)]
  }

  Timer {
                              id: pickerDelay
                               interval: 250
                              repeat: false

                             onTriggered: {
                                  Quickshell.execDetached(["hyprpicker"])
                                   }
                             }
        id: controlCenter
        anchors.fill: parent
        visible: root.expanded && !root.launcher && !root.powermenu 
        z: 10
        clip: true
        property bool dnd: false
        property real volume: 0.88
        property bool playing: false

        Rectangle {
            anchors.fill: parent
            color: root.colBg 
            radius: 22
            clip: true
            width: 500
            height: 386
            Column {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                // DO NOT DISTURB
                Rectangle {
                    width: parent.width
                    height: 48
                    radius: 10
                    color: "#394349"
                    border.color: "#465258"

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 14
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Do Not Disturb"
                        color: "#ffffff"
                        font.pixelSize: 13
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        width: 44
                        height: 24
                        radius: 20
                        color: controlCenter.dnd
                            ? "#a6bf80" : "#566168"

                        Rectangle {
                            x: controlCenter.dnd ? 23 : 3
                            anchors.verticalCenter: parent.verticalCenter
                            width: 18
                            height: 18
                            radius: 10
                            color: "#ffffff"

                            Behavior on x {
                                NumberAnimation { duration: 150 }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: controlCenter.dnd =
                                !controlCenter.dnd
                        }
                    }
                }

                // QUICK ACTIONS
               Row {
    width: parent.width
    height: 48
    spacing: 8

    Repeater {
        model: [" ", "󰐥", "", "", "󰂯", ""]

        delegate: Rectangle {
            required property var modelData
            required property int index

            property bool active: false

            width: (controlCenter.width - 65) / 6
            height: 46
            radius: 9
            color: active ? "#4a5a4c" : "#394349"
            border.color: "#4b575c"
            
            HoverHandler {
              onHoveredChanged: parent.color = hovered ? "#a6bf80" : "#394349"
            }
             Behavior on color {
                ColorAnimation { duration: 150 }
              }
            Text {
                anchors.centerIn: parent
                text: modelData
                color: parent.active ? "#a6bf80" : "#d5cbb1"
                font.pixelSize: 14
                font.family: "Font Awesome"
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                onClicked: {
                    switch (index) {
                      case 0:
                            powermenu = false
                            expanded = false
                            launcher = true
                           break 

                      case 1:
                            expanded = false
                            powermenu = true
                            launcher = false
                            break

                        case 2:
                            expanded = false
                            Quickshell.execDetached(["alacritty", "-e", "htop"]) 
                            break

                        case 3:
                            expanded = false
                            Quickshell.execDetached(["hyprshot", "-m", "region"])
                            break

                        case 4:
                            expanded = false
                            Quickshell.execDetached(["overskride"])
                            break

                        case 5:
                            expanded = false
                            
                            pickerDelay.start() 
                            break
                    }
                }
            }
        }
    }
} 

                               
// MEDIA PLAYER
Rectangle {
    id: mediaPlayer

    property var player: Mpris.players.values.length > 0
                         ? Mpris.players.values[0] : null

    width: parent.width
    height: 180
    radius: 12
    color: "#394349"
    border.color: "#465258"

    // Album art
    Rectangle {
        x: 16
        y: 16
        width: 58
        height: 58
        radius: 10
        clip: true

        gradient: Gradient {
            GradientStop { position: 0; color: "#a8b5a0" }
            GradientStop { position: 0.5; color: "#716e5d" }
            GradientStop { position: 1; color: "#353c35" }
        }

        Text {
            anchors.centerIn: parent
            text: "♫"
            color: "#eee5d0"
            font.pixelSize: 28
            visible: !mediaPlayer.player ||
                     mediaPlayer.player.trackArtUrl === ""
        }

        Image {
            anchors.fill: parent
            source: mediaPlayer.player
                    ? mediaPlayer.player.trackArtUrl : ""
            fillMode: Image.PreserveAspectCrop
            visible: mediaPlayer.player !== null &&
                     mediaPlayer.player.trackArtUrl !== ""
        }
    }

    // Track information
    Column {
        anchors.left: parent.left
        anchors.leftMargin: 88
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.top: parent.top
        anchors.topMargin: 23
        spacing: 6

        Text {
            width: parent.width
            text: mediaPlayer.player
                  ? mediaPlayer.player.identity : "No media player"
            color: "#a6bf80"
            font.pixelSize: 10
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            text: mediaPlayer.player
                  ? (mediaPlayer.player.trackTitle || "Unknown Title")
                  : "Nothing Playing"
            color: "#eee9dc"
            font.pixelSize: 13
            font.bold: true
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            text: mediaPlayer.player
                  ? (mediaPlayer.player.trackArtist || "Unknown Artist")
                  : " "
            color: "#a6a99f"
            font.pixelSize: 11
            elide: Text.ElideRight
        }
    }

    // Playback controls
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 25
        spacing: 42

        Text {
            text: "󰒮"
            color: "#c5cbb9"
            font.pixelSize: 22
            opacity: mediaPlayer.player &&
                    mediaPlayer.player.canGoPrevious ? 1 : 0.4

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (mediaPlayer.player &&
                        mediaPlayer.player.canGoPrevious)
                        mediaPlayer.player.previous()
                }
            }
        }

        Text {
            text: mediaPlayer.player &&
                  mediaPlayer.player.isPlaying ? "󰏤" : "󰐊"
            color: "#a6bf80"
            font.pixelSize: 27

            MouseArea {
                anchors.fill: parent
                enabled: mediaPlayer.player !== null &&
                         mediaPlayer.player.canTogglePlaying

                onClicked: {
                    mediaPlayer.player.togglePlaying()
                }
            }
        }

        Text {
            text: "󰒭"
            color: "#c5cbb9"
            font.pixelSize: 22
            opacity: mediaPlayer.player &&
                    mediaPlayer.player.canGoNext ? 1 : 0.4

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (mediaPlayer.player &&
                        mediaPlayer.player.canGoNext)
                        mediaPlayer.player.next()
                }
            }
        }
    }
}
 
                // VOLUME
                Rectangle {
                    width: parent.width
                    height: 55
                    radius: 10
                    color: "#394349"
                    border.color: "#465258"
                    Text {
                        x: 13
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰕾"
                        color: "#a6bf80"
                        font.pixelSize: 20
                        font.family: "Symbols Nerd Font"
                    }

                    Rectangle {
                        x: 48
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 66
                        height: 6
                        radius: 5
                        color: "#566168"

                        Rectangle {
                            width: parent.width * controlCenter.volume
                            height: parent.height
                            radius: 5
                            color: "#a6bf80"
                        }

                        Rectangle {
                            x: parent.width * controlCenter.volume - 7
                            anchors.verticalCenter: parent.verticalCenter
                            width: 14
                            height: 14
                            radius: 10
                            color: "#e2ddca"
                        }

                       MouseArea {
    anchors.fill: parent
    anchors.margins: -10

    function updateVolume(mouseX) {
        controlCenter.volume = Math.max(0, Math.min(1, mouseX / width))
        volumeSetter.running = true
    }

    onPressed: mouse => updateVolume(mouse.x)

    onPositionChanged: mouse => {
        if (pressed)
            updateVolume(mouse.x)
    }
} 
                    }
                }
            }
        }
    } 

