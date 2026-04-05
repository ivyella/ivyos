pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Overlays
import qs.Reusables
import qs.Surfaces
import qs.Services

Item {
    id: root

    property string selectedOutput: ""
    property var pendingChanges: ({})
    property string _pendingKdl: ""

    readonly property var merged: NiriOutputs.mergedOutputs()
    readonly property var outputList: Object.keys(merged)

    readonly property real totalLogicalWidth: {
        let max = 0
        for (const key of outputList) {
            const o = merged[key]
            max = Math.max(max, o.logical.x + o.logical.width)
        }
        return max || 3840
    }
    readonly property real totalLogicalHeight: {
        let max = 0
        for (const key of outputList) {
            const o = merged[key]
            max = Math.max(max, o.logical.y + o.logical.height)
        }
        return max || 1080
    }

    // ── Layout ─────────────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.lg
        spacing: Theme.spacing.md

        // ── Header ─────────────────────────────────────────────────
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
                    text: "Displays"
                    color: Theme.color.fg0
                    font.pixelSize: Theme.font.lg
                    font.family: Theme.font.ui
                    font.weight: Font.Bold
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: NiriOutputs.ready ? "Click a monitor to configure it" : "Loading..."
                    color: Theme.color.fg1
                    font.pixelSize: Theme.font.sm
                    font.family: Theme.font.ui
                }
            }
        }

        // ── Canvas ─────────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 180
            color: Theme.color.bg0
            radius: Theme.radius.md
            clip: true

            readonly property real canvasPad: Theme.spacing.lg
            readonly property real scaleX: (width - canvasPad * 2) / root.totalLogicalWidth
            readonly property real scaleY: (height - canvasPad * 2) / root.totalLogicalHeight
            readonly property real scale: Math.min(scaleX, scaleY)

            id: canvas

            Repeater {
                model: root.outputList
                delegate: Item {
                    required property string modelData
                    readonly property var output: root.merged[modelData] ?? {}
                    readonly property bool isSelected: root.selectedOutput === modelData
                    readonly property bool isPrimary: modelData === Displays.primary
                    readonly property bool isSecondary: modelData === Displays.secondary

                    readonly property real logX: (root.pendingChanges[modelData]?.x ?? output.logical?.x ?? 0)
                    readonly property real logY: (root.pendingChanges[modelData]?.y ?? output.logical?.y ?? 0)
                    readonly property real logW: output.logical?.width ?? 1920
                    readonly property real logH: output.logical?.height ?? 1080

                    x: canvas.canvasPad + logX * canvas.scale
                    y: canvas.canvasPad + logY * canvas.scale
                    width: logW * canvas.scale
                    height: logH * canvas.scale

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 2
                        radius: Theme.radius.sm
                        color: isSelected ? Theme.color.bg3 : Theme.color.bg1
                        border.color: isPrimary   ? Theme.color.accent0
                                    : isSecondary ? Theme.color.accent1
                                    : isSelected  ? Theme.color.fg2
                                    : Theme.color.border0
                        border.width: isSelected ? 2 : 1

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 2

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: modelData
                                color: Theme.color.fg0
                                font.pixelSize: Theme.font.xs
                                font.family: Theme.font.ui
                                font.weight: Font.Bold
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: isPrimary ? "Primary" : isSecondary ? "Secondary" : ""
                                color: isPrimary ? Theme.color.accent0 : Theme.color.accent1
                                font.pixelSize: Theme.font.xs
                                font.family: Theme.font.ui
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.selectedOutput = modelData
                        }
                    }
                }
            }
        }

        // ── Detail panel ───────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.color.bg0
            radius: Theme.radius.md
            visible: root.selectedOutput !== ""

            readonly property var output: root.merged[root.selectedOutput] ?? {}
            readonly property var modes: output.modes ?? []
            readonly property int currentModeIdx: root.pendingChanges[root.selectedOutput]?.modeIdx
                                                  ?? output.current_mode ?? 0

            id: detailPanel

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacing.md
                spacing: Theme.spacing.md

                // ── Name + role buttons ─────────────────────────────
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: root.selectedOutput
                        color: Theme.color.fg0
                        font.pixelSize: Theme.font.md
                        font.family: Theme.font.ui
                        font.weight: Font.Bold
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        implicitWidth: 80
                        implicitHeight: 26
                        radius: Theme.radius.sm
                        color: Displays.primary === root.selectedOutput ? Theme.color.accent0 : Theme.color.bg1

                        Text {
                            anchors.centerIn: parent
                            text: "Primary"
                            color: Displays.primary === root.selectedOutput ? Theme.color.bg0 : Theme.color.fg2
                            font.pixelSize: Theme.font.xs
                            font.family: Theme.font.ui
                            font.weight: Font.Medium
                        }
                        MouseArea {
                            anchors.fill: parent
                            enabled: Displays.primary !== root.selectedOutput
                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: Displays.setPrimary(root.selectedOutput)
                        }
                    }

                    Rectangle {
                        implicitWidth: 80
                        implicitHeight: 26
                        radius: Theme.radius.sm
                        color: Displays.secondary === root.selectedOutput ? Theme.color.accent1 : Theme.color.bg1

                        Text {
                            anchors.centerIn: parent
                            text: "Secondary"
                            color: Displays.secondary === root.selectedOutput ? Theme.color.bg0 : Theme.color.fg2
                            font.pixelSize: Theme.font.xs
                            font.family: Theme.font.ui
                            font.weight: Font.Medium
                        }
                        MouseArea {
                            anchors.fill: parent
                            enabled: Displays.secondary !== root.selectedOutput
                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: Displays.setSecondary(root.selectedOutput)
                        }
                    }
                }

                // ── Mode picker ─────────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.md

                    Text {
                        text: "Mode"
                        color: Theme.color.fg2
                        font.pixelSize: Theme.font.xs
                        font.family: Theme.font.ui
                    }

                    ComboBox {
                        Layout.fillWidth: true
                        model: detailPanel.modes.map(m =>
                            m.width + "x" + m.height + " @ " + (m.refresh_rate / 1000).toFixed(3) + "Hz"
                        )
                        currentIndex: detailPanel.currentModeIdx
                        onCurrentIndexChanged: currentIndex = detailPanel.currentModeIdx
                        onActivated: index => {
                            const changes = Object.assign({}, root.pendingChanges)
                            changes[root.selectedOutput] = Object.assign(
                                {}, changes[root.selectedOutput] ?? {}, { modeIdx: index }
                            )
                            root.pendingChanges = changes
                        }
                    }
                }

                // ── Scale ───────────────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.md

                    Text {
                        text: "Scale"
                        color: Theme.color.fg2
                        font.pixelSize: Theme.font.xs
                        font.family: Theme.font.ui
                    }

                    Slider {
                        id: scaleSlider
                        Layout.preferredWidth: 120
                        from: 0.5
                        to: 3.0
                        stepSize: 0.25
                        value: root.pendingChanges[root.selectedOutput]?.scale
                               ?? detailPanel.output.logical?.scale ?? 1.0
                        onMoved: {
                            const changes = Object.assign({}, root.pendingChanges)
                            changes[root.selectedOutput] = Object.assign(
                                {}, changes[root.selectedOutput] ?? {}, { scale: value }
                            )
                            root.pendingChanges = changes
                        }
                    }

                    Text {
                        text: scaleSlider.value.toFixed(2) + "x"
                        color: Theme.color.fg0
                        font.pixelSize: Theme.font.xs
                        font.family: Theme.font.ui
                    }
                }

                // ── Transform ───────────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.md

                    Text {
                        text: "Transform"
                        color: Theme.color.fg2
                        font.pixelSize: Theme.font.xs
                        font.family: Theme.font.ui
                    }

                    Repeater {
                        model: ["Normal", "90", "180", "270", "Flipped", "Flipped90", "Flipped180", "Flipped270"]
                        delegate: Item {
                            required property string modelData
                            required property int index
                            readonly property string current: root.pendingChanges[root.selectedOutput]?.transform
                                                              ?? detailPanel.output.logical?.transform ?? "Normal"
                            readonly property bool isActive: modelData === current

                            width: transformText.implicitWidth + Theme.spacing.sm * 2
                            height: 26

                            Rectangle {
                                anchors.fill: parent
                                radius: Theme.radius.sm
                                color: isActive ? Theme.color.accent0 : Theme.color.bg1

                                Text {
                                    id: transformText
                                    anchors.centerIn: parent
                                    text: modelData
                                    color: isActive ? Theme.color.bg0 : Theme.color.fg2
                                    font.pixelSize: Theme.font.xs
                                    font.family: Theme.font.ui
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        const changes = Object.assign({}, root.pendingChanges)
                                        changes[root.selectedOutput] = Object.assign(
                                            {}, changes[root.selectedOutput] ?? {}, { transform: modelData }
                                        )
                                        root.pendingChanges = changes
                                    }
                                }
                            }
                        }
                    }
                }

                // ── VRR ─────────────────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.md
                    visible: detailPanel.output.vrr_supported ?? false

                    Text {
                        text: "Variable Refresh Rate"
                        color: Theme.color.fg2
                        font.pixelSize: Theme.font.xs
                        font.family: Theme.font.ui
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        id: vrrToggle
                        implicitWidth: 44
                        implicitHeight: 24
                        radius: 12

                        readonly property bool vrrActive: root.pendingChanges[root.selectedOutput]?.vrr
                                                          ?? detailPanel.output.vrr_enabled ?? false

                        color: vrrActive ? Theme.color.accent0 : Theme.color.bg1

                        Rectangle {
                            width: 18
                            height: 18
                            radius: 9
                            color: Theme.color.fg0
                            anchors.verticalCenter: parent.verticalCenter
                            x: vrrToggle.vrrActive ? parent.width - width - 3 : 3
                            Behavior on x { NumberAnimation { duration: 150 } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                const changes = Object.assign({}, root.pendingChanges)
                                changes[root.selectedOutput] = Object.assign(
                                    {}, changes[root.selectedOutput] ?? {}, { vrr: !vrrToggle.vrrActive }
                                )
                                root.pendingChanges = changes
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                // ── Apply ───────────────────────────────────────────
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.sm

                    Text {
                        id: statusText
                        Layout.fillWidth: true
                        text: ""
                        color: Theme.color.fg2
                        font.pixelSize: Theme.font.xs
                        font.family: Theme.font.ui
                    }

                    Rectangle {
                        implicitWidth: 100
                        implicitHeight: 30
                        radius: Theme.radius.sm
                        color: Theme.color.accent0

                        Text {
                            anchors.centerIn: parent
                            text: "Apply"
                            color: Theme.color.bg0
                            font.pixelSize: Theme.font.sm
                            font.family: Theme.font.ui
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.applyChanges()
                        }
                    }
                }
            }
        }

        // ── Placeholder ─────────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.color.bg0
            radius: Theme.radius.md
            visible: root.selectedOutput === ""

            Text {
                anchors.centerIn: parent
                text: "Select a monitor"
                color: Theme.color.fg2
                font.pixelSize: Theme.font.sm
                font.family: Theme.font.ui
            }
        }
    }

    // ── Apply logic ─────────────────────────────────────────────────
    function applyChanges() {
        const keys = Object.keys(pendingChanges)
        if (keys.length === 0) return

        statusText.text = "Applying..."
        let remaining = keys.length

        for (const key of keys) {
            const p = pendingChanges[key]
            const o = merged[key]
            if (!o) { remaining--; continue }

            const modeIdx = p.modeIdx ?? o.current_mode ?? 0
            const mode = o.modes?.[modeIdx]
            const config = {}

            if (mode)
                config.mode = mode.width + "x" + mode.height + "@" + (mode.refresh_rate / 1000).toFixed(3)
            if (p.scale !== undefined)
                config.scale = p.scale
            if (p.transform !== undefined)
                config.transform = p.transform.toLowerCase()
            if (p.vrr !== undefined)
                config.vrr = p.vrr
            if (p.x !== undefined && p.y !== undefined)
                config.position = { x: p.x, y: p.y }

            NiriOutputs.applyOutputIpc(key, config, (ok) => {
                remaining--
                if (remaining === 0) {
                    if (ok) {
                        statusText.text = "Applied — saving..."
                        root.writeKdl()
                    } else {
                        statusText.text = "IPC failed"
                    }
                }
            })
        }
    }

    function writeKdl() {
        const finalState = {}
        for (const key of outputList) {
            const o = merged[key]
            const p = pendingChanges[key] ?? {}
            const modeIdx = p.modeIdx ?? o.current_mode ?? 0
            finalState[key] = {
                modes: o.modes,
                current_mode: modeIdx,
                logical: {
                    x:         p.x         ?? o.logical.x,
                    y:         p.y         ?? o.logical.y,
                    scale:     p.scale     ?? o.logical.scale,
                    transform: p.transform ?? o.logical.transform,
                    width:     o.logical.width,
                    height:    o.logical.height,
                },
                vrr_enabled: p.vrr ?? o.vrr_enabled,
            }
        }
        root._pendingKdl = NiriOutputs.generateKdl(finalState)
        validateProc.running = false
        validateProc.running = true
    }

    // ── Validate ────────────────────────────────────────────────────
    Process {
        id: validateProc
        running: false
        command: ["sh", "-c",
            "tmp=$(mktemp) && printf '%s' \"$IVYKDL\" > \"$tmp\" && niri validate -c \"$tmp\"; code=$?; rm -f \"$tmp\"; exit $code"
        ]
        environment: ({
            "IVYKDL": root._pendingKdl
        })
        onExited: (code) => {
            if (code !== 0) {
                statusText.text = "Validation failed"
                console.warn("DisplayPage: niri validate failed")
                return
            }
            writeProc.running = false
            writeProc.running = true
        }
    }

    // ── Write ────────────────────────────────────────────────────────
    Process {
        id: writeProc
        running: false
        command: ["sh", "-c", "printf '%s' \"$IVYKDL\" > \"$IVYPATH\""]
        environment: ({
            "IVYKDL": root._pendingKdl,
            "IVYPATH": NiriOutputs.kdlPath
        })
        onExited: (code) => {
            if (code === 0) {
                statusText.text = "Saved"
                root.pendingChanges = {}
                NiriOutputs.reloadKdl()
            } else {
                statusText.text = "Write failed"
            }
        }
    }
}