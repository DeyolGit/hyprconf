import Quickshell
import Quickshell.Wayland
import QtQuick

Variants {
    id: wp
    property string wallpaper: "file:///home/mihailo/Pictures/island.jpg"
    model: Quickshell.screens

    PanelWindow {
        required property var modelData
        screen: modelData

        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        anchors { top: true; bottom: true; left: true; right: true }
        color: "black"

        Image {
            anchors.fill: parent
            source: wp.wallpaper
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
        }

        DropArea {
            anchors.fill: parent
            onEntered: drag => drag.accepted = drag.hasUrls
            onDropped: drop => {
                if (!drop.hasUrls) return
                const s = drop.urls[0].toString()
                if (/\.(png|jpe?g|webp|bmp|gif)$/i.test(s))
                    wp.wallpaper = s
            }
        }
    }
}
