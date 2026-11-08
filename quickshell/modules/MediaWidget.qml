import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris

Item {
    id: root

    // Prefer a player that is currently playing, otherwise the first one
    readonly property var player: {
        const list = Mpris.players.values;
        for (let i = 0; i < list.length; i++) {
            if (list[i].isPlaying)
                return list[i];
        }
        return list.length > 0 ? list[0] : null;
    }

    readonly property bool playing: player !== null && player.isPlaying

    // Change this to control how wide the widget can get
    property int maxWidth: 185

    visible: player !== null
    clip: true
    implicitHeight: 40
    implicitWidth: Math.min(row.implicitWidth, maxWidth)

    RowLayout {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        width: root.implicitWidth
        spacing: 10

        // Album art with rounded corners
        Item {
    Layout.preferredWidth: 40
    Layout.preferredHeight: 40

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: Colors.bg3
    }

    Item {
        id: artBox
        anchors.fill: parent
        visible: art.status === Image.Ready

        layer.enabled: true
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: artMask
        }

        Image {
            id: art
            anchors.fill: parent
            source: root.player ? root.player.trackArtUrl : ""
            fillMode: Image.PreferAspectCrop
            asynchronous: true
        }
    }

    Item {
        id: artMask
        anchors.fill: parent
        layer.enabled: true
        visible: false

        Rectangle {
            anchors.fill: parent
            radius: 8
        }
    }
}

        // Title row (animated bars + title) and artist underneath
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                // Animated equalizer bars, flat when paused
                // Fixed-size container so the bar heights never affect layout
                Item {
                    Layout.preferredWidth: 13
                    Layout.preferredHeight: 14
                    Layout.alignment: Qt.AlignVCenter

                    Repeater {
                        model: 3
                        Rectangle {
                            id: bar
                            required property int index
                            x: index * 5
                            width: 3
                            height: 4
                            radius: 1.5
                            color: Colors.selection
                            anchors.verticalCenter: parent.verticalCenter

                            SequentialAnimation {
                                running: root.playing
                                loops: Animation.Infinite
                                onRunningChanged: if (!running) bar.height = 4

                                PauseAnimation { duration: bar.index * 120 }
                                NumberAnimation { target: bar; property: "height"; to: 12; duration: 300; easing.type: Easing.InOutSine }
                                NumberAnimation { target: bar; property: "height"; to: 4; duration: 300; easing.type: Easing.InOutSine }
                            }
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: root.player ? root.player.trackTitle : ""
                    color: Colors.fg
                    font.pixelSize: 11
                    font.bold: false
                    font.capitalization: Font.AllUppercase
                    elide: Text.ElideRight
                }
            }

            Text {
                Layout.fillWidth: true
                text: root.player ? root.player.trackArtist : ""
                color: Qt.alpha(Colors.fg, 0.6)
                font.pixelSize: 10
                elide: Text.ElideRight
            }
        }
    }

    // Left click: play/pause. Right click: next track. Middle click: previous.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: mouse => {
            if (!root.player)
                return;
            if (mouse.button === Qt.LeftButton)
                root.player.togglePlaying();
            else if (mouse.button === Qt.RightButton)
                root.player.next();
            else if (mouse.button === Qt.MiddleButton)
                root.player.previous();
        }
    }
}
