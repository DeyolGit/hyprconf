import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Bluetooth
import Quickshell.Widgets
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts

Item {
    id: controlCenter
    anchors.fill: parent
    visible: root.expanded && !root.launcher && !root.powermenu
    z: 10
    clip: true

    // ---------- state ----------
    property bool dnd: false
    property bool nightLight: false
    property bool wifiOn: true
    property string wifiName: ""
    property string sinkName: "Audio output"
    property real volume: 0.88
    property real brightness: 1.0
    property bool showBrightness: true      // set false on a desktop PC

    readonly property var btAdapter: Bluetooth.defaultAdapter

    // ---------- tile data (index 0..4) ----------
    readonly property var tileIcons: ["\uf1eb", "\uf028", "\uf294", "\uf1f6", "\uf186"]
    readonly property var tileTitles: ["Wi-Fi", "Audio", "Bluetooth", "Peace", "Night Light"]

    function tileActive(i) {
        switch (i) {
        case 0: return wifiOn;
        case 1: return true;
        case 2: return btAdapter ? btAdapter.enabled : false;
        case 3: return dnd;
        default: return nightLight;
        }
    }

    function tileSub(i) {
        switch (i) {
        case 0: return wifiOn ? (wifiName !== "" ? wifiName : "Not connected") : "Off";
        case 1: return sinkName;
        case 2: return tileActive(2) ? "On" : "Off";
        case 3: return dnd ? "On" : "Off";
        default: return nightLight ? "On" : "Off";
        }
    }

    function tileClick(i, right) {
        switch (i) {
        case 0:
            Quickshell.execDetached(["nmcli", "radio", "wifi", wifiOn ? "off" : "on"]);
            wifiOn = !wifiOn;
            refreshSoon.restart();
            break;
        case 1:
            refresh();
            break;
        case 2:
            if (right) {
                root.expanded = false;
                Quickshell.execDetached(["overskride"]);
            } else if (btAdapter) {
                btAdapter.enabled = !btAdapter.enabled;
            }
            break;
        case 3:
            dnd = !dnd;
            Quickshell.execDetached(["dunstctl", "set-paused", dnd ? "true" : "false"]);
            break;
        case 4:
            nightLight = !nightLight;
            if (nightLight)
                Quickshell.execDetached(["hyprsunset", "-t", "4000"]);
            else
                Quickshell.execDetached(["pkill", "hyprsunset"]);
            break;
        }
    }

    function setSlider(i, v) {
        if (i === 0) {
            volume = v;
            volTimer.restart();
        } else {
            brightness = v;
            brightTimer.restart();
        }
    }

    function refresh() {
        volGet.running = true;
        sinkGet.running = true;
        wifiGet.running = true;
        if (showBrightness)
            brightGet.running = true;
    }
    onVisibleChanged: if (visible) refresh()
    Component.onCompleted: refresh()

    // ---------- readers ----------
    Process {
        id: volGet
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            onStreamFinished: {
                const v = parseFloat(text.split(" ")[1]);
                if (!isNaN(v))
                    controlCenter.volume = Math.min(1, v);
            }
        }
    }

    Process {
        id: sinkGet
        command: ["sh", "-c", "wpctl inspect @DEFAULT_AUDIO_SINK@ | grep -m1 node.description | cut -d'\"' -f2"]
        stdout: StdioCollector {
            onStreamFinished: {
                const s = text.trim();
                if (s !== "")
                    controlCenter.sinkName = s;
            }
        }
    }

    Process {
        id: wifiGet
        // line 1: enabled/disabled, line 2: connected SSID (if any)
        command: ["sh", "-c", "nmcli radio wifi; nmcli -t -f active,ssid dev wifi | grep '^yes' | head -1 | cut -d: -f2"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.split("\n");
                controlCenter.wifiOn = lines[0].trim() === "enabled";
                controlCenter.wifiName = lines.length > 1 ? lines[1].trim() : "";
            }
        }
    }

    Process {
        id: brightGet
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                const p = parseInt(text.split(",")[3]);
                if (!isNaN(p))
                    controlCenter.brightness = p / 100;
            }
        }
    }

    // ---------- setters (debounced while dragging) ----------
    Timer {
        id: volTimer
        interval: 50
        onTriggered: Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", controlCenter.volume.toFixed(2)])
    }

    Timer {
        id: brightTimer
        interval: 50
        onTriggered: Quickshell.execDetached(["brightnessctl", "set", Math.max(1, Math.round(controlCenter.brightness * 100)) + "%"])
    }

    Timer {
        id: refreshSoon
        interval: 700
        onTriggered: controlCenter.refresh()
    }

    Timer {
        id: pickerDelay
        interval: 250
        onTriggered: Quickshell.execDetached(["hyprpicker"])
    }

    // ---------- background ----------
    Rectangle {
        anchors.fill: parent
        color: Colors.bg0
        radius: 22
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        // HEADER: back button, title, quick actions
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            spacing: 10

            Rectangle {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                radius: 18
                color: Colors.bg2

                Text {
                    anchors.centerIn: parent
                    text: "\uf060"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 14
                    color: Colors.fg
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.expanded = false
                }
            }

            Text {
                text: "Control Center"
                font.pixelSize: 15
                font.bold: true
                color: Colors.fg
            }

            Item { Layout.fillWidth: true }

            // launcher, power menu, htop, screenshot, color picker
            Repeater {
                model: ["\uf011", "\uf080", "\uf030", "\uf1fb"]

                delegate: Rectangle {
                    required property string modelData
                    required property int index

                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    radius: 16
                    color: actionHover.hovered ? Colors.selection : Colors.bg2
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 13
                        color: actionHover.hovered ? Colors.bg0 : Colors.fg
                    }

                    HoverHandler { id: actionHover }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            switch (index) {

                            case 0:
                                root.expanded = false;
                                root.powermenu = true;
                                root.launcher = false;
                                break;
                            case 1:
                                root.expanded = false;
                                Quickshell.execDetached(["alacritty", "-e", "htop"]);
                                break;
                            case 2:
                                root.expanded = false;
                                Quickshell.execDetached(["hyprshot", "-m", "region"]);
                                break;
                            case 3:
                                root.expanded = false;
                                pickerDelay.start();
                                break;
                            }
                        }
                    }
                }
            }
        }

        // TILES: 6-column grid, first two tiles span 3 columns, the rest span 2
        Item {
            id: grid
            Layout.fillWidth: true
            Layout.preferredHeight: 44 * 2 + 10
            readonly property real gap: 10
            readonly property real cell: (width - 2 * gap) / 3

            Repeater {
                model: 5

                delegate: Rectangle {
                    id: tile
                    required property int index
                    readonly property int span: index === 1 ? 2 : 1
                    readonly property int col: index < 2 ? index : index - 2
                    readonly property int row: index < 2 ? 0 : 1
                    readonly property bool active: controlCenter.tileActive(index)

                    x: col * (grid.cell + grid.gap)
                    y: row * (44 + grid.gap)
                    width: grid.cell * span + grid.gap * (span - 1)
                    height: 44
                    radius: 16
                    color: active ? Colors.selection : Colors.bg2
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8

                        Rectangle {
                            Layout.preferredWidth: 28
                            Layout.preferredHeight: 28
                            radius: 14
                            color: tile.active ? Qt.rgba(0, 0, 0, 0.12) : Colors.bg3

                            Text {
                                anchors.centerIn: parent
                                text: controlCenter.tileIcons[tile.index]
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 13
                                color: tile.active ? Colors.bg0 : Colors.fg
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Text {
                                Layout.fillWidth: true
                                text: controlCenter.tileTitles[tile.index]
                                font.pixelSize: 11
                                font.bold: true
                                color: tile.active ? Colors.bg0 : Colors.fg
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: controlCenter.tileSub(tile.index)
                                font.pixelSize: 9
                                color: tile.active ? Qt.alpha(Colors.bg0, 0.7) : Qt.alpha(Colors.fg, 0.6)
                                elide: Text.ElideRight
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: mouse => controlCenter.tileClick(tile.index, mouse.button === Qt.RightButton)
                    }
                }
            }
        }

        // SLIDERS: index 0 = volume, index 1 = brightness
        Repeater {
            model: controlCenter.showBrightness ? 2 : 1

            delegate: Rectangle {
                id: sl
                required property int index
                readonly property real val: index === 0 ? controlCenter.volume : controlCenter.brightness

                Layout.fillWidth: true
                Layout.preferredHeight: 36
                radius: height / 2
                color: Colors.bg2

                Rectangle {
                    width: Math.max(parent.height, parent.width * sl.val)
                    height: parent.height
                    radius: height / 2
                    color: Colors.selection
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenter: parent.verticalCenter
                    text: sl.index === 0 ? "\uf028" : "\uf185"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 16
                    color: Colors.bg0
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onPressed: mouse => controlCenter.setSlider(sl.index, Math.max(0, Math.min(1, mouse.x / width)))
                    onPositionChanged: mouse => {
                        if (pressed)
                            controlCenter.setSlider(sl.index, Math.max(0, Math.min(1, mouse.x / width)));
                    }
                }
            }
        }

        // MEDIA PLAYER
        ClippingRectangle {
            id: media
            Layout.fillWidth: true
            Layout.preferredHeight: 120
            radius: 22
            color: Colors.bg2

            // prefer a player that is playing, else the first one
            readonly property var player: {
                const list = Mpris.players.values;
                for (let i = 0; i < list.length; i++) {
                    if (list[i].isPlaying)
                        return list[i];
                }
                return list.length > 0 ? list[0] : null;
            }
            readonly property bool playing: player !== null && player.isPlaying
            readonly property real progress: (player && player.length > 0) ? Math.min(1, player.position / player.length) : 0

            // Mpris position doesn't tick by itself
            Timer {
                running: media.playing && controlCenter.visible
                interval: 1000
                repeat: true
                triggeredOnStart: true
                onTriggered: if (media.player) media.player.positionChanged()
            }

            // blurred album art background
            Image {
                anchors.fill: parent
                source: media.player ? media.player.trackArtUrl : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: status === Image.Ready
                layer.enabled: true
                layer.effect: MultiEffect {
                    blurEnabled: true
                    blur: 1.0
                    blurMax: 48
                    autoPaddingEnabled: false
                }
            }

            // darken so text stays readable
            Rectangle {
                anchors.fill: parent
                color: Colors.bg0
                opacity: 0.5
            }

            // output device line
            Row {
                x: 16
                y: 10
                spacing: 6
                Text {
                    text: "\uf027"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 10
                    color: Qt.alpha(Colors.fg, 0.8)
                }
                Text {
                    width: media.width - 60
                    text: controlCenter.sinkName
                    font.pixelSize: 10
                    color: Qt.alpha(Colors.fg, 0.8)
                    elide: Text.ElideRight
                }
            }

            // title + artist
            Column {
                x: 16
                y: 34
                width: media.width - 16 - 76
                spacing: 2

                Text {
                    width: parent.width
                    text: media.player ? (media.player.trackTitle || "Unknown title") : "Nothing playing"
                    font.pixelSize: 15
                    font.bold: true
                    font.capitalization: Font.AllUppercase
                    color: Colors.fg
                    elide: Text.ElideRight
                }
                Text {
                    width: parent.width
                    text: media.player ? (media.player.trackArtist || "Unknown artist") : ""
                    font.pixelSize: 11
                    color: Qt.alpha(Colors.fg, 0.8)
                    elide: Text.ElideRight
                }
            }

            // big play/pause button
            Rectangle {
                anchors.right: parent.right
                anchors.rightMargin: 16
                y: 30
                width: 46
                height: 46
                radius: 23
                color: Colors.fg
                opacity: media.player ? 1 : 0.4

                Text {
                    anchors.centerIn: parent
                    text: media.playing ? "\uf04c" : "\uf04b"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 16
                    color: Colors.bg0
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: media.player !== null && media.player.canTogglePlaying
                    onClicked: media.player.togglePlaying()
                }
            }

            // prev / progress / next
            RowLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                anchors.bottomMargin: 12
                height: 20
                spacing: 10

                Text {
                    text: "\uf048"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 11
                    color: Colors.fg
                    opacity: media.player && media.player.canGoPrevious ? 1 : 0.4
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -6
                        onClicked: if (media.player && media.player.canGoPrevious) media.player.previous()
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 4
                    radius: 2
                    color: Qt.alpha(Colors.fg, 0.3)

                    Rectangle {
                        width: parent.width * media.progress
                        height: parent.height
                        radius: 2
                        color: Colors.fg
                    }
                }

                Text {
                    text: "\uf051"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 11
                    color: Colors.fg
                    opacity: media.player && media.player.canGoNext ? 1 : 0.4
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -6
                        onClicked: if (media.player && media.player.canGoNext) media.player.next()
                    }
                }
            }
        }
    }
}
