pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    // ── exposed state ─────────────────────────────────────────────
    property string activeWindow: ""
    property string activeAppId: ""
    property var iconMap: ({})
    property bool fullscreen: false
    property string currentOutput: ""

    // ── helpers ────────────────────────────────────────────────────
    function normalize(id) {
        return (id || "")
            .toLowerCase()
            .replace(".desktop", "")
            .trim()
    }

    function iconFor(appId) {
        const icon = iconMap?.[appId] ?? ""
        return icon ? Quickshell.iconPath(icon, true) : ""
    }

    // ── signals (optional but useful for debugging / hooks) ───────
    signal windowChanged()
    signal appChanged()
    

    // ── window watcher ────────────────────────────────────────────
    Process {
        id: windowProc
        command: [
            "sh", "-c",
            "niri msg focused-window | grep 'App ID:' | awk -F '\"' '{print $2}'"
        ]

        stdout: SplitParser {
            onRead: data => {
                if (!data || !data.trim()) return

                const id = normalize(data)

                const names = {
                    kitty: "Terminal",
                    librewolf: "LibreWolf",
                    "dev.zed.zed": "Zed",
                    "org.gnome.nautilus": "Files",
                    spotify: "Spotify",
                    steam: "Steam",
                    vesktop: "Discord"
                }

                activeAppId = id
                activeWindow = names[id] ?? id

                appChanged()
                windowChanged()

                windowProc.running = false
            }
        }

        Component.onCompleted: running = true
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: windowProc.running = true
    }

    // ── icon scanner ───────────────────────────────────────────────
    Process {
        id: iconScanner
        command: [
            "bash", "-c",
            "find /run/current-system/sw/share/applications ~/.local/share/applications -name '*.desktop' 2>/dev/null" +
            " | while read f; do" +
            " id=$(basename \"$f\" .desktop);" +
            " icon=$(grep -m1 '^Icon=' \"$f\" | cut -d= -f2-);" +
            " [ -n \"$icon\" ] && echo \"$id|$icon\";" +
            " done"
        ]

        stdout: SplitParser {
            onRead: data => {
                const parts = data.split("|")
                if (parts.length !== 2) return

                const map = Object.assign({}, iconMap)
                map[normalize(parts[0])] = parts[1].trim()
                iconMap = map
            }
        }

        Component.onCompleted: running = true
    }
}