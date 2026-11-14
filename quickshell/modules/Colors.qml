pragma Singleton
import Quickshell
import QtQuick

Singleton {
    id: root
    property string theme: "original"

    readonly property var themes: ({
        original: {
            bg0: "#040e0d", bg1: "#0a1816", bg2: "#0f211f",
            bg3: "#152a26", bg4: "#1d3631",
            selection: "#49E2AF", fg: "#f5e2c5",
            red: "#ff6048", orange: "#ffa478", yellow: "#f5cd5b",
            green: "#7ad9a8", aqua: "#3dd1b0", blue: "#5fc8d4",
            purple: "#e89aa8"
        },
        catppuccin: {
            bg0: "#11111b", bg1: "#181825", bg2: "#1e1e2e",
            bg3: "#313244", bg4: "#45475a",
            selection: "#94e2d5", fg: "#cdd6f4",
            red: "#f38ba8", orange: "#fab387", yellow: "#f9e2af",
            green: "#a6e3a1", aqua: "#94e2d5", blue: "#74c7ec",
            purple: "#cba6f7"
        },
        everforest: {
            bg0: "#232a2e", bg1: "#2d353b", bg2: "#343f44",
            bg3: "#3d484d", bg4: "#475258",
            selection: "#a7c080", fg: "#d3c6aa",
            red: "#e67e80", orange: "#e69875", yellow: "#dbbc7f",
            green: "#a7c080", aqua: "#83c092", blue: "#7fbbb3",
            purple: "#d699b6"
        },
        nord: {
            bg0: "#242933", bg1: "#2e3440", bg2: "#3b4252",
            bg3: "#434c5e", bg4: "#4c566a",
            selection: "#88c0d0", fg: "#e5e9f0",
            red: "#bf616a", orange: "#d08770", yellow: "#ebcb8b",
            green: "#a3be8c", aqua: "#8fbcbb", blue: "#81a1c1",
            purple: "#b48ead"
        },
       tokyonight: {
            bg0: "#16161e", bg1: "#1a1b26", bg2: "#1f2335",
            bg3: "#292e42", bg4: "#414868",
            selection: "#7aa2f7", fg: "#c0caf5",
            red: "#f7768e", orange: "#ff9e64", yellow: "#e0af68",
            green: "#9ece6a", aqua: "#73daca", blue: "#7dcfff",
            purple: "#bb9af7"
        },
        mono: {
            bg0: "#101010", bg1: "#171717", bg2: "#1f1f1f",
            bg3: "#2b2b2b", bg4: "#3a3a3a",
            selection: "#d0d0d0", fg: "#e4e4e4",
            red: "#b5857f", orange: "#b39a85", yellow: "#b8ae8a",
            green: "#8fa38f", aqua: "#8aa3a0", blue: "#8a9aab",
            purple: "#a393ab"
        },
        autumn: {
             bg0: "#030c18", bg1: "#081624", bg2: "#0d2033",
             bg3: "#132b42", bg4: "#1b3a57",
            selection: "#e3a03a", fg: "#f3e6d3",
            red: "#e2653f", orange: "#ee9b45", yellow: "#f0c75e",
            green: "#7fb48e", aqua: "#55bfc4", blue: "#5ba7e6",
            purple: "#c99aa0"
        },
    })

    readonly property var active: themes[theme] ?? themes.catppuccin

    readonly property color bg0: active.bg0
    readonly property color bg1: active.bg1
    readonly property color bg2: active.bg2
    readonly property color bg3: active.bg3
    readonly property color bg4: active.bg4
    readonly property color selection: active.selection
    readonly property color fg: active.fg

    readonly property color red: active.red
    readonly property color orange: active.orange
    readonly property color yellow: active.yellow
    readonly property color green: active.green
    readonly property color aqua: active.aqua
    readonly property color blue: active.blue
    readonly property color purple: active.purple
}
