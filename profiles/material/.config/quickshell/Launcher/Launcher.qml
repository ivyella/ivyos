pragma Singleton
pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.Common
import qs.Config

Singleton {
    id: root
    property bool launcherVisible: false
    property var apps: []
    property string query: ""
    property bool scanning: false

    property var filteredApps: {
        if (query.trim() === "") return apps
        const q = query.toLowerCase()
        return apps.filter(a => a.name.toLowerCase().includes(q))
    }

    Component.onCompleted: root.rescan()

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

    function rescan() {
        root.apps = []
        root.scanning = true
        scanner.running = true
    }

    // scan desktop files and parse them
    Process {
        id: scanner
        command: [
            "bash", "-c",
            "find /run/current-system/sw/share/applications ~/.local/share/applications -name '*.desktop' 2>/dev/null | while read f; do " +
            "name=$(grep -m1 '^Name=' \"$f\" | cut -d= -f2-); " +
            "exec=$(grep -m1 '^Exec=' \"$f\" | cut -d= -f2- | sed 's/ *%[^ ]*//g' | sed 's/^ *//;s/ *$//'); " +
            "icon=$(grep -m1 '^Icon=' \"$f\" | cut -d= -f2-); " +
            "nodisplay=$(grep -m1 '^NoDisplay=' \"$f\" | cut -d= -f2-); " +
            "if [ -n \"$name\" ] && [ -n \"$exec\" ] && [ \"$nodisplay\" != 'true' ]; then " +
            "echo \"$name|$exec|$icon\"; fi; done | sort -t'|' -k1 -f"
        ]
        stdout: SplitParser {
            onRead: data => {
                const parts = data.split("|")
                if (parts.length >= 2) {
                    const entry = {
                        name: parts[0].trim(),
                        exec: parts[1].trim(),
                        icon: parts.length >= 3 ? parts[2].trim() : ""
                    }
                    root.apps = [...root.apps, entry]
                }
            }
        }
        onRunningChanged: {
            if (!running) root.scanning = false
        }
    }

    // launch a command detached from quickshell
    Process {
        id: launcher
        command: ["bash", "-c", ""]
    }

    function launch(exec) {
        launcher.command = ["bash", "-c", "nohup " + exec + " >/dev/null 2>&1 &disown"]
        launcher.running = true
        root.launcherVisible = false
        root.query = ""
    }

    function show() {
        root.query = ""
        root.launcherVisible = true
    }

    function hide() {
        root.launcherVisible = false
        root.query = ""
    }

    PanelWindow {
        visible: root.launcherVisible
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        MouseArea {
            anchors.fill: parent
            onClicked: root.hide()
        }

        Rectangle {
            id: panel
            anchors.centerIn: parent
            width: 600
            height: 500
            radius: Theme.radius.lg
            color: Theme.color.bg1
            border.width: 2
            border.color: Theme.color.border0
            focus: true

            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Escape) {
                    root.hide()
                } else if (event.key === Qt.Key_Down) {
                    listView.incrementCurrentIndex()
                    event.accepted = true
                } else if (event.key === Qt.Key_Up) {
                    listView.decrementCurrentIndex()
                    event.accepted = true
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    if (listView.currentIndex >= 0 && listView.currentIndex < root.filteredApps.length) {
                        root.launch(root.filteredApps[listView.currentIndex].exec)
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

            MouseArea { anchors.fill: parent; onClicked: {} }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacing.lg
                spacing: Theme.spacing.md

                // search bar
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
                                        root.launch(root.filteredApps[listView.currentIndex].exec)
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

                // app list
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

                            width: listView.width
                            height: 44
                            radius: Theme.radius.sm
                            color: listView.currentIndex === index
                                ? Theme.color.bg3
                                : hovered ? Theme.color.bg2 : "transparent"

                            property bool hovered: false

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onEntered: {
                                    appItem.hovered = true
                                    listView.currentIndex = index
                                }
                                onExited: appItem.hovered = false
                                onClicked: root.launch(appItem.modelData.exec)
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
                                    color: listView.currentIndex === index
                                        ? Theme.color.fg0
                                        : Theme.color.fg1
                                    font.pixelSize: Theme.font.md
                                    font.family: Theme.font.ui
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
