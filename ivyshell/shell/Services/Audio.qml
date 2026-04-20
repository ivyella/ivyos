pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int volume: 0
    property bool muted: false

    // ── Get ───────────────────────────────────────────────────────
    function refresh() {
        volGetProc.running = false
        volGetProc.running = true
    }

    Process {
        id: volGetProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => {
                const m = data.match(/Volume:\s*([\d.]+)/)
                if (m) root.volume = Math.round(parseFloat(m[1]) * 100)
                root.muted = data.includes("[MUTED]")
            }
        }
        Component.onCompleted: running = true
    }

    // ── Set ───────────────────────────────────────────────────────
    function setVolume(val) {
        root.volume = Math.max(0, Math.min(100, val))
        Quickshell.execDetached([
            "wpctl", "set-volume",
            "@DEFAULT_AUDIO_SINK@",
            root.volume + "%", "-l", "1.0"
        ])
    }

    function adjustVolume(delta) {
        setVolume(root.volume + delta)
    }

    function toggleMute() {
        Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"])
        refresh()
    }

    // ── Poll ──────────────────────────────────────────────────────
    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}