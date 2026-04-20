pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool enabled:   false
    property bool available: false
    property string connectedDevice: ""

    // ── Check if bluetooth hardware exists ────────────────────────────────────
    Process {
        id: checkProc
        command: ["rfkill", "list", "bluetooth"]
        stdout: StdioCollector {
            onStreamFinished: () => {
                root.available = this.text.trim() !== ""
                if (root.available) statusProc.running = true
            }
        }
        Component.onCompleted: running = true
    }

    // ── Get status ────────────────────────────────────────────────────────────
    function refresh() {
        if (!root.available) return
        statusProc.running = false
        statusProc.running = true
    }

    Process {
        id: statusProc
        command: ["bluetoothctl", "show"]
        property bool _powered: false
        stdout: SplitParser {
            onRead: data => {
                if (data.includes("Powered: yes")) statusProc._powered = true
            }
        }
        onRunningChanged: {
            if (running) {
                _powered = false
            } else {
                root.enabled = _powered
                if (root.enabled) deviceProc.running = true
            }
        }
        onExited: (code) => {
            if (code !== 0) console.warn("Bluetooth: bluetoothctl show exited", code)
        }
    }

    // ── Get connected device ──────────────────────────────────────────────────
    Process {
        id: deviceProc
        command: ["bluetoothctl", "info"]
        property string _name: ""
        stdout: SplitParser {
            onRead: data => {
                if (data.includes("Name:"))
                    deviceProc._name = data.split("Name:")[1].trim()
            }
        }
        onRunningChanged: {
            if (!running) root.connectedDevice = _name
        }
    }

    // ── Toggle ────────────────────────────────────────────────────────────────
    function toggle() {
        if (!root.available) return
        const next = !root.enabled
        Quickshell.execDetached([
            "bluetoothctl", "power", next ? "on" : "off"
        ])
        root.enabled = next
        if (!next) root.connectedDevice = ""
    }

    // ── Poll ──────────────────────────────────────────────────────────────────
    Timer {
        interval: 10000
        running:  root.available
        repeat:   true
        onTriggered: root.refresh()
    }
}