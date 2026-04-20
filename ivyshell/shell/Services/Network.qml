pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool   enabled:        false
    property string ssid:           "Disconnected"
    property string connectionType: "" // "ethernet", "wifi", or ""

    readonly property string icon: connectionType === "ethernet" ? "router"
                                 : connectionType === "wifi"     ? "wifi"
                                 :                                 "wifi_off"

    readonly property string label: connectionType === "ethernet" ? "Ethernet"
                                  : connectionType === "wifi"     ? ssid
                                  :                                 "Disconnected"

    // ── Refresh connection type ───────────────────────────────────────────────
    function refresh() {
        typeProc.running = false
        typeProc.running = true
    }

    Process {
        id: typeProc
        command: ["nmcli", "-t", "-f", "TYPE", "con", "show", "--active"]
        stdout: StdioCollector {
            onStreamFinished: () => {
                const types = this.text.split("\n")
                const first = types[0] ?? ""
                if (first.includes("ethernet"))      root.connectionType = "ethernet"
                else if (first.includes("wireless")) root.connectionType = "wifi"
                else                                 root.connectionType = ""
                root.enabled = root.connectionType !== ""
            }
        }
    }

    // ── Refresh SSID (wifi only) ──────────────────────────────────────────────
    Process {
        id: ssidProc
        command: ["nmcli", "-t", "-f", "ACTIVE,SSID", "dev", "wifi"]
        property string _matched: ""
        stdout: SplitParser {
            onRead: data => {
                if (data.startsWith("yes:"))
                    ssidProc._matched = data.split(":")[1] ?? ""
            }
        }
        onRunningChanged: {
            if (running) {
                _matched = ""
            } else {
                root.ssid    = _matched !== "" ? _matched : "Disconnected"
                _matched = ""
            }
        }
    }

    // ── Toggle ────────────────────────────────────────────────────────────────
    function toggle() {
        Quickshell.execDetached(["nmcli", "radio", "wifi", root.enabled ? "off" : "on"])
        Qt.callLater(refresh)
    }

    // ── Monitor for changes ───────────────────────────────────────────────────
    Process {
        running: true
        command: ["nmcli", "monitor"]
        stdout: SplitParser {
            onRead: () => {
                root.refresh()
                if (root.connectionType === "wifi") ssidProc.running = true
            }
        }
    }

    Component.onCompleted: {
        refresh()
        ssidProc.running = true
    }
}