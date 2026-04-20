pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int  level:     100
    property bool available: false

    // ── Check if brightnessctl exists and has a device ────────────────────────
    Process {
        id: checkProc
        command: ["brightnessctl", "-l", "-c", "backlight"]
        stdout: StdioCollector {
            onStreamFinished: () => {
                root.available = this.text.trim() !== ""
                if (root.available) getProc.running = true
            }
        }
        onExited: (code) => {
            if (code !== 0) root.available = false
        }
        Component.onCompleted: running = true
    }

    // ── Get ───────────────────────────────────────────────────────────────────
    function refresh() {
        if (!root.available) return
        getProc.running = false
        getProc.running = true
    }

    Process {
        id: getProc
        command: ["brightnessctl", "-m"]
        stdout: SplitParser {
            onRead: data => {
                const parts = data.split(",")
                if (parts.length > 3) {
                    const val = parseInt(parts[3].replace("%", ""))
                    if (!isNaN(val)) root.level = val
                }
            }
        }
        onExited: (code) => {
            if (code !== 0) console.warn("Brightness: brightnessctl get exited", code)
        }
    }

    // ── Set ───────────────────────────────────────────────────────────────────
    function setLevel(val) {
        if (!root.available) return
        root.level = Math.max(1, Math.min(100, val))
        Quickshell.execDetached(["brightnessctl", "s", root.level + "%"])
    }

    function adjust(delta) {
        setLevel(root.level + delta)
    }

    // ── Poll ──────────────────────────────────────────────────────────────────
    Timer {
        interval: 5000
        running:  root.available
        repeat:   true
        onTriggered: root.refresh()
    }
}