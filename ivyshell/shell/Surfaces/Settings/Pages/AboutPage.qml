// Settings/Pages/AboutPage.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Reusables.Theme
import qs.Reusables.MdIcons

Item {
    id: root

    property var systemInfo: null
    property bool systemInfoLoading: true
    property bool systemInfoAvailable: true
    property string userString: "—"

    onVisibleChanged: {
        if (visible) root.refreshAll()
    }

    Timer {
        interval: 60000
        running: root.visible
        repeat: true
        onTriggered: root.refreshAll()
    }

    Process {
        id: userProc
        command: ["bash", "-c", "echo $(whoami)@$(hostname)"]
        stdout: StdioCollector {
            onStreamFinished: root.userString = text.trim()
        }
        Component.onCompleted: running = true
    }

    Process {
        id: checkFastfetchProcess
        command: ["sh", "-c", "command -v fastfetch"]
        running: false
        onExited: (exitCode) => {
            if (exitCode === 0) fastfetchProcess.running = true
            else { root.systemInfoLoading = false; root.systemInfoAvailable = false }
        }
        Component.onCompleted: running = true
        stdout: StdioCollector {}
        stderr: StdioCollector {}
    }

    Process {
        id: fastfetchProcess
        command: ["fastfetch", "--format", "json", "--config", Quickshell.shellDir + "/Services/InfoFetcher/system-info.jsonc"] 
        running: false
        onExited: (exitCode) => {
            root.systemInfoLoading = false
            if (exitCode === 0) {
                try {
                    root.systemInfo = JSON.parse(stdout.text)
                    root.systemInfoAvailable = true
                } catch (e) {
                    root.systemInfoAvailable = false
                }
            } else {
                root.systemInfoAvailable = false
            }
        }
        stdout: StdioCollector {}
        stderr: StdioCollector {}
    }

    function getModule(type) {
        if (!root.systemInfo) return null
        return root.systemInfo.find(m => m.type === type)
    }

    function refreshAll() {
        root.systemInfo = null
        root.systemInfoLoading = true
        root.systemInfoAvailable = true
        userProc.running = true
        checkFastfetchProcess.running = true
    }

    function formatUptime(seconds) {
        const days = Math.floor(seconds / 86400)
        const hours = Math.floor((seconds % 86400) / 3600)
        const minutes = Math.floor((seconds % 3600) / 60)
        if (days > 0) return `${days}d ${hours}h ${minutes}m`
        if (hours > 0) return `${hours}h ${minutes}m`
        return `${minutes}m`
    }

    function getRows() {
        if (!root.systemInfo) return []
        const os = getModule("OS")
        const kernel = getModule("Kernel")
        const wm = getModule("WM")
        const cpu = getModule("CPU")
        const gpu = getModule("GPU")
        const mem = getModule("Memory")
        const disk = getModule("Disk")
        const uptime = getModule("Uptime")

        const cpuCores = cpu?.result?.cores?.logical
        const memUsed = mem?.result ? (mem.result.used / (1024*1024*1024)).toFixed(1) : null
        const memTotal = mem?.result ? (mem.result.total / (1024*1024*1024)).toFixed(1) : null
        const uptimeVal = uptime?.result?.uptime
        const wmName = wm?.result?.prettyName || wm?.result?.processName || "—"
        const wmVersion = wm?.result?.version ? ` ${wm.result.version}` : ""

        const ignoredMounts = ["/nix/store", "/boot", "/tmp", "/run"]
        const diskRows = []
        if (disk?.result && Array.isArray(disk.result)) {
            disk.result
                .filter(d => d?.bytes && !ignoredMounts.some(m => d.mountpoint.startsWith(m)))
                .forEach(d => {
                    const used = (d.bytes.used / (1024*1024*1024)).toFixed(1)
                    const total = (d.bytes.total / (1024*1024*1024)).toFixed(1)
                    const pct = d.bytes.total > 0
                        ? Math.round(d.bytes.used / d.bytes.total * 100)
                        : 0
                    diskRows.push({
                        label: `Disk (${d.mountpoint})`,
                        value: `${used} GB / ${total} GB (${pct}%)`
                    })
                })
        }

        return [
            { group: true, label: "System" },
            { label: "User",   value: root.userString },
            { label: "OS",     value: os?.result?.prettyName || "—" },
            { label: "Kernel", value: kernel?.result?.release || "—" },
            { label: "WM",     value: wmName + wmVersion },
            { label: "UI",     value: "IvyShell v0.1" },
            { group: true, label: "Hardware" },
            { label: "CPU",    value: cpu?.result?.cpu ? cpu.result.cpu + (cpuCores ? ` (${cpuCores} threads)` : "") : "—" },
            { label: "GPU",    value: gpu?.result?.[0]?.name || "—" },
            { label: "Memory", value: memUsed ? `${memUsed} GiB / ${memTotal} GiB` : "—" },
            ...diskRows,
            { group: true, label: "Session" },
            { label: "Uptime", value: uptimeVal ? formatUptime(uptimeVal / 1000) : "—" },
        ]
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.lg
        spacing: Theme.spacing.md

        // Header
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: headerCol.implicitHeight + Theme.spacing.lg * 2
            color: Theme.color.bg0
            radius: Theme.radius.md

            ColumnLayout {
                id: headerCol
                anchors.centerIn: parent
                spacing: Theme.spacing.xs

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "About"
                    color: Theme.color.fg0
                    font.pixelSize: Theme.font.lg
                    font.family: Theme.font.ui
                    font.weight: Font.Bold
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "System Info"
                    color: Theme.color.fg1
                    font.pixelSize: Theme.font.sm
                    font.family: Theme.font.ui
                }
            }
        }

        // Info
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.color.bg0
            radius: Theme.radius.md

            Column {
                visible: !root.systemInfoAvailable
                anchors.centerIn: parent
                spacing: Theme.spacing.xs

                Text {
                    text: "fastfetch is not installed"
                    color: Theme.color.fg1
                    font.pixelSize: Theme.font.sm
                    font.family: Theme.font.ui
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "Install fastfetch to view system information"
                    color: Theme.color.fg2
                    font.pixelSize: Theme.font.xs
                    font.family: Theme.font.ui
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            Text {
                visible: root.systemInfoLoading && root.systemInfoAvailable
                anchors.centerIn: parent
                text: "Loading..."
                color: Theme.color.fg2
                font.pixelSize: Theme.font.sm
                font.family: Theme.font.ui
            }

            ListView {
                visible: !root.systemInfoLoading && root.systemInfoAvailable
                anchors.fill: parent
                anchors.margins: Theme.spacing.md
                clip: true
                interactive: false
                model: root.systemInfo ? root.getRows() : []

                delegate: Item {
                    required property var modelData
                    width: ListView.view.width
                    height: modelData.group ? 32 : 30

                    Text {
                        visible: modelData.group ?? false
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.label ?? ""
                        color: Theme.color.accent0
                        font.pixelSize: Theme.font.md
                        font.family: Theme.font.ui
                        font.weight: Font.Bold
                    }

                    RowLayout {
                        visible: !(modelData.group ?? false)
                        anchors.fill: parent
                        spacing: Theme.spacing.md

                        Text {
                            Layout.preferredWidth: 120
                            text: modelData.label ?? ""
                            color: Theme.color.fg2
                            font.pixelSize: Theme.font.sm
                            font.family: Theme.font.ui
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.value ?? "—"
                            color: Theme.color.fg0
                            font.pixelSize: Theme.font.sm
                            font.family: Theme.font.ui
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }
}