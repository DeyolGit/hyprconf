import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import QtQuick.Controls
import Quickshell.Widgets

Item {
    id: soundBar
    anchors.fill: parent
    z: 10
    clip: true
    visible: root.volumeBar && !root.launcher && !root.expanded && !root.powermenu

    property real volume: 0
    property bool muted: false
    readonly property real step: 0.05

    function setVolume(v) {
        if (muted) {
            muted = false;
            Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "0"]);
        }
        volume = Math.max(0, Math.min(1, v));
        setTimer.restart();
    }

    function toggleMute() {
        muted = !muted;
        Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]);
    }

    // when the bar opens: read the real volume and grab keyboard focus
    onVisibleChanged: {
        if (visible) {
            getter.running = true;
            forceActiveFocus();
        }
    }

    Process {
        id: getter
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            onStreamFinished: {
                const v = parseFloat(text.split(" ")[1]);
                if (!isNaN(v))
                    soundBar.volume = Math.min(1, v);
                soundBar.muted = text.indexOf("MUTED") !== -1;
            }
        }
    }

    // writes the volume once input pauses for 40ms
    Timer {
        id: setTimer
        interval: 40
        onTriggered: Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", soundBar.volume.toFixed(2)])
    }

    Keys.onPressed: event => {
        switch (event.key) {
        case Qt.Key_Left:
        case Qt.Key_Down:
            setVolume(volume - step);
            event.accepted = true;
            break;
        case Qt.Key_Right:
        case Qt.Key_Up:
            setVolume(volume + step);
            event.accepted = true;
            break;
        case Qt.Key_M:
            toggleMute();
            event.accepted = true;
            break;
        case Qt.Key_Escape:
        case Qt.Key_Return:
        case Qt.Key_Enter:
            root.volumeBar = false;
            event.accepted = true;
            break;
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        spacing: 12

        Text {
            text: (soundBar.muted || soundBar.volume === 0) ? "\uf026"
                : soundBar.volume < 0.5 ? "\uf027" : "\uf028"
            font.family: "Symbols Nerd Font"
            font.pixelSize: 15
            color: soundBar.muted ? Colors.red : Colors.fg
            Layout.preferredWidth: 20
        }

        Rectangle {
            id: track
            Layout.fillWidth: true
            Layout.preferredHeight: 8
            radius: 4
            color: Colors.bg3

            Rectangle {
                height: parent.height
                width: parent.width * (soundBar.muted ? 0 : soundBar.volume)
                radius: 4
                color: Colors.selection
                Behavior on width {
                    NumberAnimation { duration: 80 }
                }
            }

            // mouse works too: click, drag, scroll
            MouseArea {
                anchors.fill: parent
                anchors.margins: -8
                cursorShape: Qt.PointingHandCursor
                onPressed: m => soundBar.setVolume((m.x - 8) / track.width)
                onPositionChanged: m => {
                    if (pressed)
                        soundBar.setVolume((m.x - 8) / track.width);
                }
                onWheel: w => soundBar.setVolume(soundBar.volume + (w.angleDelta.y > 0 ? soundBar.step : -soundBar.step))
            }
        }

        Text {
            text: Math.round(soundBar.volume * 100) + "%"
            font.pixelSize: 13
            font.family: root.fontFamily
            font.bold: false
            color: Colors.fg
            horizontalAlignment: Text.AlignRight
            Layout.preferredWidth: 38
        }
    }
}