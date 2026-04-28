pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool enabled: false
    property int temp: 4000  // kelvin, adjust to taste

    function toggle() {
        if (root.enabled) {
            disable();
        } else {
            enable();
        }
    }

    function enable() {
        startProc.running = true;
        root.enabled = true;
    }

    function disable() {
        killProc.running = true;
        root.enabled = false;
    }

    Process {
        id: startProc
        running: false
        command: ["wlsunset", "-t", root.temp.toString(), "-T", (root.temp + 1).toString()]
    }

    Process {
        id: killProc
        running: false
        command: ["pkill", "-x", "wlsunset"]
        onExited: root.enabled = false
    }

    // ── Check if already running on startup ───────────────────────────────────
    Process {
        command: ["pgrep", "-x", "wlsunset"]
        stdout: SplitParser {
            onRead: data => {
                if (data.trim() !== "") {
                    root.enabled = true;
                } else {
                    console.log("wlsunset is not running at startup.");
                }
            }
        }
        Component.onCompleted: running = true
    }
}
