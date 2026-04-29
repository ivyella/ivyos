pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    // ── exposed state ─────────────────────────────────────────────
    property string activeWindow: ""
    property string activeAppId: ""
    property var iconMap: ({})

    property bool fullscreen: false
    property string currentOutput: ""

    // ── dock state ────────────────────────────────────────────────
    property var runningApps: ({})
    property var dockModel: []

    // ── signals ───────────────────────────────────────────────────
   
    signal appChanged()

    // ───────────────────────────────────────────────────────────────
    // ICON SYSTEM
    // ───────────────────────────────────────────────────────────────

    function normalize(id) {
        return (id || "")
            .toLowerCase()
            .replace(/\.desktop$/, "")
            .replace(/^.*\//, "")
            .trim()
    }

   function iconFor(appId) {  
            const _dep = iconMap  
    const decodedAppId = decodeURIComponent(appId)  
    const key = normalize(decodedAppId)  
    const icon = iconMap[key]  
      
    console.log("iconFor:", appId, "-> decoded:", decodedAppId, "-> key:", key, "-> iconMap:", icon)  
      
    
        if (icon && icon.length > 0) {  
            if (icon.startsWith("/") || icon.startsWith("~/"))  
                return icon  
    
            const resolved = Quickshell.iconPath(icon, true)  
            if (resolved && resolved.length > 0)  
                return resolved  
        }  
    
        const byId = Quickshell.iconPath(key, true)  
        if (byId && byId.length > 0)  
            return byId  
    
        return Quickshell.iconPath(key, false) || "image://icon/" + key  
    }

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

                root.activeAppId = id
                root.activeWindow = names[id] ?? id

                root.appChanged()
                root.windowChanged()

                windowProc.running = false
            }
        }

        Component.onCompleted: running = true
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            if (!windowProc.running)
                windowProc.running = true
        }
    }

    // ── window list parsing ────────────────────────────────────────
function parseNiriOutput(output) {  
    const map = {}  
    const lines = output.split("\n")  
    let current = null  
  
    function flush() {  
        if (current && current.appId) {  
            if (!map[current.appId])  
                map[current.appId] = []  
            map[current.appId].push(current)  
        }  
        current = null  
    }  
  
    for (let line of lines) {  
        const t = line.trim()  
  
        if (t.startsWith("Window ID")) {  
            flush()  
            const m = t.match(/Window ID (\d+)/)  
            current = {  
                appId: "",  
                title: "",  
                focused: false,  
                windowId: m ? parseInt(m[1]) : -1  
            }  
            continue  
        }  
  
        if (!current) continue  
  
        if (t.startsWith("App ID:")) {  
            // Remove quotes and clean up  
            let appId = t.slice("App ID:".length).trim()  
            appId = appId.replace(/^"|"$/g, '') // Remove surrounding quotes  
            current.appId = normalize(appId)  
        } else if (t.startsWith("Title:")) {  
            current.title = t.slice("Title:".length).trim()  
        } else if (t.includes("(focused)")) {  
            current.focused = true  
        }  
    }  
  
    flush()  
    return map  
}

    Process {
        id: niriProcess
        command: ["niri", "msg", "windows"]

        stdout: StdioCollector {
            onStreamFinished: {
                const parsed = root.parseNiriOutput(text)

                root.runningApps = parsed

                root.dockModel = Object.keys(parsed).map(id => ({
                    appId: id,
                    winCount: parsed[id].length,
                    windows: parsed[id],
                    focusId: parsed[id][0]?.windowId ?? -1,
                    focused: parsed[id].some(w => w.focused)
                }))

                // Re-run icon scanner if any new app IDs have appeared
                // that we don't have icons for yet
                const needsScan = Object.keys(parsed).some(id => !root.iconMap[id])
                if (needsScan && !iconScanner.running)
                    iconScanner.running = true

                niriProcess.running = false
            }
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            if (!niriProcess.running)
                niriProcess.running = true
        }
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

                const key = normalize(parts[0])
                const value = parts[1].trim()

                // Object.assign copy triggers reactivity on iconMap,
                // which re-evaluates any bindings that reference it
                const copy = Object.assign({}, root.iconMap)
                copy[key] = value
                root.iconMap = copy
            }
        }

        Component.onCompleted: running = true
    }
}
