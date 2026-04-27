pragma Singleton
pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.Reusables.Theme
import qs.Reusables.MdIcons

Singleton {
    id: root
    property bool launcherVisible: false
    property var apps: []
    property string query: ""
    property bool scanning: false

    property var launchCounts: ({})
    property var pinnedApps: []
    property bool dataLoaded: false

    property var filteredApps: {
        const q = query.trim().toLowerCase()
        let list = q === ""
            ? apps.slice()
            : apps.filter(a => a.name.toLowerCase().includes(q))

        list.sort((a, b) => {
            const aPinned = root.pinnedApps.indexOf(a.name)
            const bPinned = root.pinnedApps.indexOf(b.name)
            const aIsPinned = aPinned !== -1
            const bIsPinned = bPinned !== -1

            if (aIsPinned && bIsPinned) return aPinned - bPinned
            if (aIsPinned) return -1
            if (bIsPinned) return 1

            const aCount = root.launchCounts[a.name] || 0
            const bCount = root.launchCounts[b.name] || 0
            if (bCount !== aCount) return bCount - aCount

            return a.name.localeCompare(b.name)
        })

        return list
    }

    IpcHandler {
        target: "launcher"
        function toggle(): void {
            if (root.launcherVisible) {
                root.hide()
            } else {
                root.show()
            }
        }
    }

    // ── Persistence ──────────────────────────────────────────────────────────

    FileView {
        id: dataFile
        path: Quickshell.env("HOME").toString() + "/.config/ivyshell/launcher_data.json"
        blockLoading: true

        JsonAdapter {
            id: adapter
            property var counts
            property var pinned
        }

        onLoaded: {
            root.launchCounts = adapter.counts || {}
            root.pinnedApps   = adapter.pinned  || []
            root.dataLoaded   = true
            root.rescan()
        }

        onLoadFailed: {
            root.launchCounts = {}
            root.pinnedApps   = []
            root.dataLoaded   = true
            root.save()
            root.rescan()
        }

        Component.onCompleted: reload()
    }

    function save() {
        adapter.counts = root.launchCounts
        adapter.pinned = root.pinnedApps
        dataFile.writeAdapter()
    }

    function togglePin(appName) {
        const idx = root.pinnedApps.indexOf(appName)
        let pins = root.pinnedApps.slice()
        if (idx === -1) {
            pins.unshift(appName)
        } else {
            pins.splice(idx, 1)
        }
        root.pinnedApps = pins
        root.save()
    }

    // ── Scanning ─────────────────────────────────────────────────────────────

    function rescan() {
        root.apps = []
        root.scanning = true
        scanner.running = true
    }

    Process {
        id: scanner
        command: [
            "bash", "-c",
            "find /run/current-system/sw/share/applications ~/.local/share/applications /var/lib/flatpak/exports/share/applications ~/.local/share/flatpak/exports/share/applications -name '*.desktop' 2>/dev/null" +
            " | while read f; do " +
            "name=$(grep -m1 '^Name=' \"$f\" | cut -d= -f2-); " +
            "exec=$(grep -m1 '^Exec=' \"$f\" | cut -d= -f2- | sed 's/ *%[^ ]*//g' | sed 's/^ *//;s/ *$//'); " +
            "icon=$(grep -m1 '^Icon=' \"$f\" | cut -d= -f2-); " +
            "nodisplay=$(grep -m1 '^NoDisplay=' \"$f\" | cut -d= -f2-); " +
            "if [ -n \"$name\" ] && [ -n \"$exec\" ] && [ \"$nodisplay\" != 'true' ]; then " +
            "echo \"$name|$exec|$icon\"; fi; done"
        ]
        stdout: SplitParser {
            onRead: data => {
                const parts = data.split("|")
                if (parts.length >= 2) {
                    const name = parts[0].trim()
                    if (root.apps.some(a => a.name === name)) return
                    root.apps = [...root.apps, {
                        name: name,
                        exec: parts[1].trim(),
                        icon: parts.length >= 3 ? parts[2].trim() : ""
                    }]
                }
            }
        }
        onRunningChanged: {
            if (!running) root.scanning = false
        }
    }

    // ── Launching ─────────────────────────────────────────────────────────────

    Process {
        id: launcher
        command: ["bash", "-c", ""]
    }

    function launch(app) {
        const counts = Object.assign({}, root.launchCounts)
        counts[app.name] = (counts[app.name] || 0) + 1
        root.launchCounts = counts
        root.save()

        launcher.command = ["bash", "-c", "nohup " + app.exec + " >/dev/null 2>&1 &disown"]
        launcher.running = true
        root.hide()
    }

    function show() {
        root.query = ""
        root.launcherVisible = true
    }

    function hide() {
        root.launcherVisible = false
        root.query = ""
    }

    // ── UI ────────────────────────────────────────────────────────────────────

    property var contextApp: null
    property bool contextVisible: false
    property real contextX: 0
    property real contextY: 0

    PanelWindow {
        visible: root.launcherVisible
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore


        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (root.contextVisible) {
                    root.contextVisible = false
                } else {
                    root.hide()
                }
            }
        }

        Rectangle {
            id: panel
            anchors.centerIn: parent
            width: 600
            height: 500
            radius: Theme.radius.lg
            color: Theme.color.bg1
            border.width: 0
            border.color: Theme.color.border0
            focus: true

            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Escape) {
                    if (root.contextVisible) {
                        root.contextVisible = false
                    } else {
                        root.hide()
                    }
                } else if (event.key === Qt.Key_Down) {
                    listView.incrementCurrentIndex()
                    event.accepted = true
                } else if (event.key === Qt.Key_Up) {
                    listView.decrementCurrentIndex()
                    event.accepted = true
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    if (listView.currentIndex >= 0 && listView.currentIndex < root.filteredApps.length) {
                        root.launch(root.filteredApps[listView.currentIndex])
                    }
                    event.accepted = true
                }
            }

            onVisibleChanged: {
                if (visible) {
                    forceActiveFocus()
                    searchInput.forceActiveFocus()
                }
            }

            MouseArea { anchors.fill: parent; onClicked: { root.contextVisible = false } }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacing.lg
                spacing: Theme.spacing.md

                // ── Search bar ───────────────────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 36
                    radius: Theme.radius.md
                    color: Theme.color.bg2
                    border.width: 1
                    border.color: searchInput.activeFocus ? Theme.color.accent0 : Theme.color.border0

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.padding.md
                        anchors.rightMargin: Theme.padding.md
                        spacing: Theme.spacing.sm

                        Text {
                            text: ""
                            color: Theme.color.fg2
                            font.pixelSize: Theme.font.md
                            font.family: Theme.font.mono
                        }

                        TextInput {
                            id: searchInput
                            Layout.fillWidth: true
                            color: Theme.color.fg0
                            font.pixelSize: Theme.font.md
                            font.family: Theme.font.ui
                            selectionColor: Theme.color.accent0
                            selectedTextColor: Theme.color.bg0
                            text: root.query
                            onTextChanged: {
                                root.query = text
                                listView.currentIndex = 0
                            }
                            Keys.onPressed: (event) => {
                                if (event.key === Qt.Key_Down) {
                                    listView.incrementCurrentIndex()
                                    panel.forceActiveFocus()
                                    event.accepted = true
                                } else if (event.key === Qt.Key_Escape) {
                                    root.hide()
                                    event.accepted = true
                                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    if (listView.currentIndex >= 0 && listView.currentIndex < root.filteredApps.length) {
                                        root.launch(root.filteredApps[listView.currentIndex])
                                    }
                                    event.accepted = true
                                }
                            }
                        }

                        // refresh button
                        Rectangle {
                            width: 24
                            height: 24
                            radius: Theme.radius.sm
                            color: refreshHover.containsMouse ? Theme.color.bg3 : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: root.scanning ? "" : "󰑐"
                                color: root.scanning ? Theme.color.accent0 : Theme.color.fg2
                                font.pixelSize: Theme.font.md
                                font.family: Theme.font.mono

                                RotationAnimator on rotation {
                                    running: root.scanning
                                    from: 0; to: 360
                                    duration: 1000
                                    loops: Animation.Infinite
                                }
                            }

                            MouseArea {
                                id: refreshHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.rescan()
                            }
                        }
                    }
                }

                // ── Pinned icon row ───────────────────────────────────────────
                Flow {
                    id: pinnedFlow
                    Layout.fillWidth: true
                    visible: root.pinnedApps.length > 0
                    spacing: Theme.spacing.sm

                    Repeater {
                        model: {
                            void root.pinnedApps.length
                            return root.pinnedApps.map(name => root.apps.find(a => a.name === name)).filter(a => a !== undefined)
                        }

                        delegate: Item {
                            id: pinnedItem
                            required property var modelData
                            width: 56
                            height: col.implicitHeight + Theme.spacing.xs * 2

                            Rectangle {
                                anchors.fill: parent
                                radius: Theme.radius.sm
                                color: pinnedIconMouse.containsMouse ? Theme.color.bg3 : "transparent"
                            }

                            Column {
                                id: col
                                anchors.centerIn: parent
                                spacing: 4

                                Image {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: Theme.icon.lg
                                    height: Theme.icon.lg
                                    source: pinnedItem.modelData.icon !== ""
                                        ? "image://icon/" + pinnedItem.modelData.icon
                                        : "image://icon/application-x-executable"
                                    sourceSize: Qt.size(Theme.icon.md, Theme.icon.md)
                                    smooth: true
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: pinnedItem.width - Theme.spacing.xs * 2
                                    text: pinnedItem.modelData.name
                                    color: Theme.color.fg1
                                    font.pixelSize: Theme.font.sm
                                    font.family: Theme.font.ui
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                }
                            }

                            MouseArea {
                                id: pinnedIconMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                cursorShape: Qt.PointingHandCursor
                                onClicked: (event) => {
                                    if (event.button === Qt.RightButton) {
                                        root.contextApp = pinnedItem.modelData
                                        root.contextX = pinnedItem.mapToItem(panel, 0, pinnedItem.height + 4).x
                                        root.contextY = pinnedItem.mapToItem(panel, 0, pinnedItem.height + 4).y
                                        root.contextVisible = true
                                    } else {
                                        root.launch(pinnedItem.modelData)
                                    }
                                }
                            }
                        }
                    }
                }

                // ── App list ─────────────────────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: Theme.radius.md
                    color: "transparent"
                    clip: true

                    ListView {
                        id: listView
                        anchors.fill: parent
                        model: root.filteredApps
                        currentIndex: 0
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                        delegate: Rectangle {
                            id: appItem
                            required property var modelData
                            required property int index

                            readonly property bool isHovered: rowMouse.containsMouse
                            readonly property bool isSelected: listView.currentIndex === index

                            width: listView.width
                            height: 44
                            radius: Theme.radius.sm
                            color: isSelected ? Theme.color.bg3
                                 : isHovered  ? Theme.color.bg2
                                 : "transparent"

                            MouseArea {
                                id: rowMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onEntered: listView.currentIndex = appItem.index
                                onClicked: (event) => {
                                    if (event.button === Qt.RightButton) {
                                        root.contextApp = appItem.modelData
                                        root.contextX = appItem.mapToItem(panel, event.x, event.y).x
                                        root.contextY = appItem.mapToItem(panel, event.x, event.y).y
                                        root.contextVisible = true
                                    } else {
                                        root.launch(appItem.modelData)
                                    }
                                }
                                cursorShape: Qt.PointingHandCursor
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: Theme.padding.md
                                anchors.rightMargin: Theme.padding.md
                                spacing: Theme.spacing.md

                                Image {
                                    width: Theme.icon.md
                                    height: Theme.icon.md
                                    source: appItem.modelData.icon !== ""
                                        ? "image://icon/" + appItem.modelData.icon
                                        : "image://icon/application-x-executable"
                                    sourceSize: Qt.size(Theme.icon.md, Theme.icon.md)
                                    smooth: true
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: appItem.modelData.name
                                    color: appItem.isSelected ? Theme.color.fg0 : Theme.color.fg1
                                    font.pixelSize: Theme.font.md
                                    font.family: Theme.font.ui
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }

            // ── Context menu ─────────────────────────────────────────────────
            Rectangle {
                id: contextMenu
                visible: root.contextVisible && root.contextApp !== null
                x: Math.min(root.contextX, panel.width - width - Theme.spacing.md)
                y: Math.min(root.contextY, panel.height - height - Theme.spacing.md)
                width: 160
                implicitHeight: contextCol.implicitHeight + Theme.spacing.sm * 2
                radius: Theme.radius.md
                color: Theme.color.bg2
                border.width: 1
                border.color: Theme.color.border0
                z: 10

                Column {
                    id: contextCol
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: Theme.spacing.sm
                    }
                    spacing: 2

                    Rectangle {
                        width: parent.width
                        height: 32
                        radius: Theme.radius.sm
                        color: ctxPinMouse.containsMouse ? Theme.color.bg3 : "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: Theme.padding.sm
                            anchors.rightMargin: Theme.padding.sm
                            spacing: Theme.spacing.sm

                            Text {
                                text: {
                                    void root.pinnedApps.length
                                    if (root.contextApp === null) return ""
                                    return root.pinnedApps.indexOf(root.contextApp.name) !== -1 ? "󰐃" : "󰐄"
                                }
                                color: Theme.color.fg2
                                font.pixelSize: Theme.font.sm
                                font.family: Theme.font.mono
                            }

                            Text {
                                Layout.fillWidth: true
                                text: {
                                    void root.pinnedApps.length
                                    if (root.contextApp === null) return ""
                                    return root.pinnedApps.indexOf(root.contextApp.name) !== -1 ? "Unpin" : "Pin"
                                }
                                color: Theme.color.fg1
                                font.pixelSize: Theme.font.sm
                                font.family: Theme.font.ui
                            }
                        }

                        MouseArea {
                            id: ctxPinMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.togglePin(root.contextApp.name)
                                root.contextVisible = false
                            }
                        }
                    }
                }
            }
        }
    }
}
