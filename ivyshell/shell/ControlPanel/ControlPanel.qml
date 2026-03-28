pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.Common

Singleton {
    id: root
    property bool visible: false

    property int volume: 0
    property int brightness: 0
    property string wifiNetwork: "Disconnected"
    property bool wifiEnabled: false
    property bool bluetoothEnabled: false
    property bool nightLightEnabled: false
    property bool dndEnabled: false

    IpcHandler {
        target: "controlpanel"
        function toggle(): void {
            root.visible = !root.visible
        }
    }

    // ── Volume ────────────────────────────────────────────────────────────
    Process {
        id: volProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => {
                const match = data.match(/Volume:\s*([\d.]+)/)
                if (match) root.volume = Math.round(parseFloat(match[1]) * 100)
            }
        }
    }

    Process {
        id: volSetProc
        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "50%"]
    }

    function setVolume(val) {
        root.volume = val
        volSetProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", val + "%", "-l", "1.0"]
        volSetProc.running = true
    }

    // ── Brightness ────────────────────────────────────────────────────────
    Process {
        id: brightGetProc
        command: ["bash", "-c", "brightnessctl -m | cut -d, -f4 | tr -d '%'"]
        stdout: SplitParser {
            onRead: data => {
                const val = parseInt(data.trim())
                if (!isNaN(val)) root.brightness = val
            }
        }
    }

    Process {
        id: brightSetProc
        command: ["brightnessctl", "set", "50%"]
    }

    function setBrightness(val) {
        root.brightness = val
        brightSetProc.command = ["brightnessctl", "set", val + "%"]
        brightSetProc.running = true
    }

    // ── WiFi ──────────────────────────────────────────────────────────────
    Process {
        id: wifiProc
        command: ["bash", "-c", "nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2"]
        stdout: SplitParser {
            onRead: data => {
                const ssid = data.trim()
                root.wifiEnabled = ssid !== ""
                root.wifiNetwork = ssid !== "" ? ssid : "Disconnected"
            }
        }
    }

    Process {
        id: wifiToggleProc
        command: ["nmcli", "radio", "wifi", "on"]
    }

    function toggleWifi() {
        wifiToggleProc.command = ["nmcli", "radio", "wifi", root.wifiEnabled ? "off" : "on"]
        wifiToggleProc.running = true
        Qt.callLater(() => wifiProc.running = true)
    }

    // ── Bluetooth ─────────────────────────────────────────────────────────
    Process {
        id: bluetoothProc
        command: ["bash", "-c", "bluetoothctl show | grep Powered"]
        stdout: SplitParser {
            onRead: data => root.bluetoothEnabled = data.includes("yes")
        }
    }

    Process {
        id: bluetoothSetProc
        command: ["bluetoothctl", "power", "on"]
    }

    function toggleBluetooth() {
        bluetoothSetProc.command = ["bluetoothctl", "power", root.bluetoothEnabled ? "off" : "on"]
        bluetoothSetProc.running = true
        root.bluetoothEnabled = !root.bluetoothEnabled
    }

    // ── Polling ───────────────────────────────────────────────────────────
    Timer {
        interval: 2000
        running: root.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            volProc.running = true
            brightGetProc.running = true
            bluetoothProc.running = true
            wifiProc.running = true
        }
    }

    // ── UI ────────────────────────────────────────────────────────────────
    PanelWindow {
        visible: root.visible
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        MouseArea {
            anchors.fill: parent
            onClicked: root.visible = false
        }

        Rectangle {
            id: panel
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 40
            anchors.rightMargin: 10
            width: 320
            height: contentCol.implicitHeight + Theme.spacing.lg * 2
            color: Theme.color.bg0
            radius: Theme.radius.md
            border.width: 1
            border.color: Theme.color.border0

            focus: true
            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Escape) root.visible = false
            }
            onVisibleChanged: if (visible) forceActiveFocus()

            MouseArea { anchors.fill: parent; onClicked: {} }

            ColumnLayout {
                id: contentCol
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: Theme.spacing.lg
                spacing: Theme.spacing.md

                // ── Tiles ─────────────────────────────────────────────────
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    rowSpacing: Theme.spacing.sm
                    columnSpacing: Theme.spacing.sm

                    ControlTile {
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        icon: root.wifiEnabled ? "wifi" : "wifi_off"
                        label: root.wifiEnabled ? root.wifiNetwork : "Wi-Fi Off"
                        active: root.wifiEnabled
                        onToggled: root.toggleWifi()
                    }

                    ControlTile {
                        Layout.fillWidth: true
                        icon: "bluetooth"
                        label: "Bluetooth"
                        active: root.bluetoothEnabled
                        onToggled: root.toggleBluetooth()
                    }

                    ControlTile {
                        Layout.fillWidth: true
                        icon: "nightlight"
                        label: "Night Light"
                        active: root.nightLightEnabled
                        onToggled: root.nightLightEnabled = !root.nightLightEnabled
                    }

                    ControlTile {
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        icon: root.dndEnabled ? "notifications_off" : "notifications"
                        label: "Do Not Disturb"
                        active: root.dndEnabled
                        onToggled: root.dndEnabled = !root.dndEnabled
                    }
                }

                // ── Sliders ───────────────────────────────────────────────
                ControlSlider {
                    Layout.fillWidth: true
                    icon: root.volume == 0 ? "volume_off" : root.volume < 50 ? "volume_down" : "volume_up"
                    label: "Volume"
                    value: root.volume
                    onMoved: (val) => root.setVolume(val)
                }

                ControlSlider {
                    Layout.fillWidth: true
                    icon: "brightness_5"
                    label: "Brightness"
                    value: root.brightness
                    onMoved: (val) => root.setBrightness(val)
                }
            }
        }
    }

    // ── ControlTile ───────────────────────────────────────────────────────
    component ControlTile: Rectangle {
        id: tile
        property string icon: ""
        property string label: ""
        property bool active: false
        signal toggled()

        implicitHeight: 64
        radius: Theme.radius.md
        color: active ? Theme.color.accent0 : (tileHover.containsMouse ? Theme.color.bg3 : Theme.color.bg2)

        Behavior on color { ColorAnimation { duration: 150 } }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.spacing.md
            spacing: Theme.spacing.xs

            MdIcons {
                text: tile.icon
                iconSize: Theme.icon.sm
                color: tile.active ? Theme.color.bg0 : Theme.color.fg1
                fill: tile.active ? 1 : 0
            }

            Text {
                Layout.fillWidth: true
                text: tile.label
                color: tile.active ? Theme.color.bg0 : Theme.color.fg1
                font.pixelSize: Theme.font.xs
                font.family: Theme.font.ui
                elide: Text.ElideRight
            }
        }

        MouseArea {
            id: tileHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: tile.toggled()
        }
    }

    // ── ControlSlider ─────────────────────────────────────────────────────
    component ControlSlider: Rectangle {
        id: sliderTile
        property string icon: ""
        property string label: ""
        property int value: 0
        signal moved(int val)

        implicitHeight: 64
        radius: Theme.radius.md
        color: Theme.color.bg2

        RowLayout {
            anchors.fill: parent
            anchors.margins: Theme.spacing.md
            spacing: Theme.spacing.sm

            MdIcons {
                text: sliderTile.icon
                iconSize: Theme.icon.sm
                color: Theme.color.accent0
                fill: 1
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.xs

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: sliderTile.label
                        color: Theme.color.fg1
                        font.pixelSize: Theme.font.xs
                        font.family: Theme.font.ui
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: sliderTile.value + "%"
                        color: Theme.color.fg2
                        font.pixelSize: Theme.font.xs
                        font.family: Theme.font.ui
                    }
                }

                Slider {
                    Layout.fillWidth: true
                    from: 0
                    to: 100
                    value: sliderTile.value
                    onMoved: sliderTile.moved(Math.round(value))

                    background: Rectangle {
                        x: parent.leftPadding
                        y: parent.topPadding + parent.availableHeight / 2 - height / 2
                        width: parent.availableWidth
                        height: 4
                        radius: 2
                        color: Theme.color.bg3

                        Rectangle {
                            width: parent.parent.visualPosition * parent.width
                            height: parent.height
                            radius: parent.radius
                            color: Theme.color.accent0
                        }
                    }

                    handle: Rectangle {
                        x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                        y: parent.topPadding + parent.availableHeight / 2 - height / 2
                        width: 14
                        height: 14
                        radius: 7
                        color: Theme.color.accent0
                    }
                }
            }
        }
    }
}