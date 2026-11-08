import QtQuick
import Quickshell.Services.Mpris

// Animated equalizer bars. Only visible while any player is playing.
Item {
    id: root

    property color color: Colors.selection

    readonly property bool playing: {
        const list = Mpris.players.values;
        for (let i = 0; i < list.length; i++) {
            if (list[i].isPlaying)
                return true;
        }
        return false;
    }

    visible: playing
    implicitWidth: 13
    implicitHeight: 14

    Repeater {
        model: 3

        Rectangle {
            id: bar
            required property int index
            x: index * 5
            width: 3
            height: 4
            radius: 1.5
            color: root.color
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
