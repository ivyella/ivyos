pragma Singleton
pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Mpris
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.Reusables.Theme
import qs.Reusables.MdIcons
import qs.Services.Notification
import qs.Reusables.Components

Singleton {
    id: root

    // ── visibility ────────────────────────────────────────────────────────────
    property bool visible: false

    // ── accordion state ───────────────────────────────────────────────────────
    property bool settingsExpanded:      true
    property bool notificationsExpanded: true

    // ── system state ──────────────────────────────────────────────────────────
    property int    volume:            0
    property int    brightness:        0
    property string wifiNetwork:       "Disconnected"
    property bool   wifiEnabled:       false
    property bool   bluetoothEnabled:  false
    property bool   nightLightEnabled: false
    property bool   dndEnabled:        false

    // ── interaction debounce ──────────────────────────────────────────────────
    // prevents the polling timer from clobbering slider values right after the
    // user drags them
    property bool _userInteracting: false

    Timer {
        id:       interactDebounce
        interval: 2000
        repeat:   false
        onTriggered: root._userInteracting = false
    }

    function _markInteracting() {
        root._userInteracting = true
        interactDebounce.restart()
    }

    // ── IPC ───────────────────────────────────────────────────────────────────
    IpcHandler {
        target: "quickpanel"
        function toggle(): void { root.visible = !root.visible }
    }

    // ── polling ───────────────────────────────────────────────────────────────
    function poll() {
        if (!root.visible || root._userInteracting) return
        volProc.running       = true
        brightGetProc.running = true
        wifiProc.running      = true
        btStatusProc.running  = true
    }
    function toggle() {  
        root.visible = !root.visible  
    }  
    onVisibleChanged: if (visible) poll()

    Timer {
        interval: 5000
        running:  root.visible
        repeat:   true
        onTriggered: root.poll()
    }

    // ── volume ────────────────────────────────────────────────────────────────
    Process {
        id: volProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => {
                const m = data.match(/Volume:\s*([\d.]+)/)
                if (m) root.volume = Math.round(parseFloat(m[1]) * 100)
            }
        }
        onExited: (code) => {
            if (code !== 0) console.warn("QuickPanel: wpctl get-volume exited", code)
        }
    }

    function setVolume(val) {
        root._markInteracting()
        root.volume = val
        Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", val + "%", "-l", "1.0"])
    }

    // ── brightness ────────────────────────────────────────────────────────────
    Process {
        id: brightGetProc
        command: ["brightnessctl", "-m"]
        stdout: SplitParser {
            onRead: data => {
                const parts = data.split(",")
                if (parts.length > 3) {
                    const val = parseInt(parts[3].replace("%", ""))
                    if (!isNaN(val)) root.brightness = val
                }
            }
        }
        onExited: (code) => {
            if (code !== 0) console.warn("QuickPanel: brightnessctl get exited", code)
        }
    }

    function setBrightness(val) {
        root._markInteracting()
        root.brightness = val
        Quickshell.execDetached(["brightnessctl", "s", val + "%"])
    }

    // ── wifi ──────────────────────────────────────────────────────────────────
    Process {
        id: wifiProc
        command: ["nmcli", "-t", "-f", "ACTIVE,SSID", "dev", "wifi"]
        property string _matched: ""
        stdout: SplitParser {
            onRead: data => {
                if (data.startsWith("yes:"))
                    wifiProc._matched = data.split(":")[1] ?? ""
            }
        }
        onRunningChanged: {
            if (!running) {
                root.wifiNetwork = _matched !== "" ? _matched : "Disconnected"
                root.wifiEnabled = _matched !== ""
                _matched = ""
            }
        }
        onExited: (code) => {
            if (code !== 0) console.warn("QuickPanel: nmcli exited", code)
        }
    }

    function setWifi(enable) {
        root.wifiEnabled = enable
        Quickshell.execDetached(["nmcli", "radio", "wifi", enable ? "on" : "off"])
    }

    // ── bluetooth ─────────────────────────────────────────────────────────────
    Process {
        id: btStatusProc
        command: ["bluetoothctl", "show"]
        property bool _powered: false
        stdout: SplitParser {
            onRead: data => {
                if (data.includes("Powered: yes")) btStatusProc._powered = true
            }
        }
        onRunningChanged: {
            if (running) {
                _powered = false        // reset accumulator each run
            } else {
                root.bluetoothEnabled = _powered
            }
        }
        onExited: (code) => {
            if (code !== 0) console.warn("QuickPanel: bluetoothctl exited", code)
        }
    }

    function setBluetooth(enable) {
        root.bluetoothEnabled = enable
        Quickshell.execDetached(["bluetoothctl", "power", enable ? "on" : "off"])
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  WINDOW
    // ══════════════════════════════════════════════════════════════════════════
    PanelWindow {
        visible: root.visible
        WlrLayershell.layer:         WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        MouseArea {
            anchors.fill: parent
            z: -1
            onClicked: root.visible = false
        }

        Column {
            anchors.top:         parent.top
            anchors.right:       parent.right
            anchors.topMargin:   40
            anchors.rightMargin: 10
            width:   340
            spacing: 8

                PanelCard {
        title:      "Quick Settings"
        icon:       "tune"
        isExpanded: root.settingsExpanded
        onHeaderClicked: root.settingsExpanded = !root.settingsExpanded

        GridLayout {
            width:         parent.width
            columns:       2
            columnSpacing: 7
            rowSpacing:    7

            ControlTile {
                Layout.fillWidth: true
                icon:    root.wifiEnabled ? "wifi" : "wifi_off"
                label:   "Wi-Fi"
                active:  root.wifiEnabled
                onToggled: root.setWifi(!root.wifiEnabled)
            }

            ControlTile {
                Layout.fillWidth: true
                icon:    "bluetooth"
                label:   "Bluetooth"
                active:  root.bluetoothEnabled
                onToggled: root.setBluetooth(!root.bluetoothEnabled)
            }

            ControlTile {
                Layout.fillWidth: true
                icon:    "bedtime"
                label:   "Night Light"
                active:  root.nightLightEnabled
                onToggled: root.nightLightEnabled = !root.nightLightEnabled
            }

            ControlTile {
                Layout.fillWidth: true
                icon:    root.dndEnabled ? "notifications_off" : "notifications"
                label:   "Do Not Disturb"
                active:  root.dndEnabled
                onToggled: root.dndEnabled = !root.dndEnabled
            }
        }

        ControlSlider {
            width: parent.width
            icon:  root.volume === 0 ? "volume_off" : "volume_up"
            label: "Volume"
            value: root.volume
            onUserChanged: val => root.setVolume(val)
        }

        ControlSlider {
            width: parent.width
            icon:  "brightness_5"
            label: "Brightness"
            value: root.brightness
            onUserChanged: val => root.setBrightness(val)
        }
    }


    // ── Quick Settings card ───────────────────────────────────────────


            // ── Notifications card ────────────────────────────────────────────
            PanelCard {
                title:      "Notifications"
                icon:       NotiServer.history.length > 0 ? "notifications_unread" : "notifications"
                isExpanded: root.notificationsExpanded
                onHeaderClicked: root.notificationsExpanded = !root.notificationsExpanded
                headerButton:      NotiServer.history.length > 0
                headerButtonLabel: "Clear"
                onHeaderButtonClicked: NotiServer.history = []

                Item {
                    width:  parent.width
                    height: notifList.count > 0
                            ? Math.min(notifList.contentHeight, 400)
                            : emptyLabel.implicitHeight + 24
                    clip: true

                    ListView {
                        id:           notifList
                        anchors.fill: parent
                        model:        NotiServer.history
                        spacing:      6
                        clip:         true
                        delegate:     NotificationDelegate {}

                        add:    Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 180 } }
                        remove: Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 140 } }
                    }

                    Text {
                        id:               emptyLabel
                        anchors.centerIn: parent
                        visible:          notifList.count === 0
                        text:             "No notifications"
                        color:            Theme.color.fg2
                        font.family:      Theme.font.ui
                        font.pixelSize:   Theme.font.sm
                    }
                }
            }
        }
    }

    // ══════════════════════════════════════════════════════════════════════════
    //  COMPONENTS
    // ══════════════════════════════════════════════════════════════════════════

    // ── PanelCard ─────────────────────────────────────────────────────────────
    component PanelCard: Rectangle {
        id: card
        property string title:             ""
        property string icon:              ""
        property bool   isExpanded:        true
        property bool   headerButton:      false
        property string headerButtonLabel: ""
        signal headerClicked()
        signal headerButtonClicked()
        default property alias contents: bodyCol.children

        width:          parent.width
        implicitHeight: headerRow.height
                        + (isExpanded ? bodyCol.implicitHeight + 20 : 0)
                        + 20
        radius:         Theme.radius.lg
        color:          Theme.color.bg0
        border.color:   Theme.color.border0
        border.width:   0
        clip:           true

        Behavior on implicitHeight {
            NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
        }

        Item {
            id:     headerRow
            width:  parent.width
            height: 44

            RowLayout {
                anchors {
                    fill:        parent
                    leftMargin:  14
                    rightMargin: 14
                }
                spacing: 8

                MdIcons {
                    text:     card.icon
                    color:    Theme.color.accent0
                    iconSize: 16
                    fill:     1
                }

                Text {
                    text:             card.title
                    Layout.fillWidth: true
                    color:            Theme.color.fg0
                    font.pixelSize:   Theme.font.sm
                    font.family:      Theme.font.ui
                    font.weight:      Font.Medium
                }

                Rectangle {
                    width:   52
                    height:  22
                    radius:  11
                    visible: card.headerButton
                    color:   clearHover.containsMouse
                             ? Theme.color.accent0
                             : Theme.color.bg2

                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text:            card.headerButtonLabel
                        color:           clearHover.containsMouse
                                         ? Theme.color.bg0
                                         : Theme.color.fg1
                        font.pixelSize:  10
                        font.family:     Theme.font.ui
                    }

                    MouseArea {
                        id:           clearHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape:  Qt.PointingHandCursor
                        onPressed:    mouse => mouse.accepted = true
                        onClicked:    mouse => {
                            mouse.accepted = true
                            card.headerButtonClicked()
                        }
                    }
                }

                MdIcons {
                    text:     card.isExpanded ? "expand_less" : "expand_more"
                    color:    Theme.color.fg2
                    iconSize: 16
                }
            }

            // header click behind clear button
            MouseArea {
                anchors.fill: parent
                cursorShape:  Qt.PointingHandCursor
                z:            -1
                onPressed:    mouse => mouse.accepted = true
                onClicked:    mouse => {
                    mouse.accepted = true
                    card.headerClicked()
                }
            }
        }

        Column {
            id: bodyCol
            anchors {
                top:          headerRow.bottom
                left:         parent.left
                right:        parent.right
                leftMargin:   14
                rightMargin:  14
                bottomMargin: 14
            }
            spacing: 8
            opacity: card.isExpanded ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 180 } }
        }
    }

    // ── SectionLabel ──────────────────────────────────────────────────────────
    component SectionLabel: Text {
        color:              Theme.color.fg2
        font.pixelSize:     9
        font.family:        Theme.font.ui
        font.weight:        Font.Medium
        font.letterSpacing: 0.8
        topPadding:         4
    }

    // ── NotificationDelegate ──────────────────────────────────────────────────
    component NotificationDelegate: Rectangle {
        required property var modelData

        width:        ListView.view.width
        height:       notifInner.implicitHeight + 18
        radius:       10
        color:        Theme.color.bg2
        border.color: Theme.color.border0
        border.width: 0

        Column {
            id: notifInner
            anchors {
                fill:    parent
                margins: 10
            }
            spacing: 3

            RowLayout {
                width: parent.width

                Text {
                    text:             modelData.appName ?? ""
                    color:            Theme.color.fg2
                    font.pixelSize:   10
                    font.family:      Theme.font.ui
                    Layout.fillWidth: true
                    elide:            Text.ElideRight
                }

                Text {
                    text: modelData.timestamp
                          ? Qt.formatDateTime(
                                new Date(Date.parse(modelData.timestamp)),
                                "hh:mm AP")
                          : ""
                    color:          Theme.color.fg2
                    font.pixelSize: 10
                    font.family:    Theme.font.ui
                }
            }

            Text {
                text:           modelData.summary ?? ""
                color:          Theme.color.fg0
                font.weight:    Font.Medium
                font.pixelSize: 13
                font.family:    Theme.font.ui
                width:          parent.width
                wrapMode:       Text.WordWrap
            }

            Text {
                text:             modelData.body ?? ""
                color:            Theme.color.fg1
                font.pixelSize:   11
                font.family:      Theme.font.ui
                width:            parent.width
                wrapMode:         Text.WordWrap
                maximumLineCount: 3
                elide:            Text.ElideRight
                visible:          (modelData.body ?? "") !== ""
            }
        }
    }
}
