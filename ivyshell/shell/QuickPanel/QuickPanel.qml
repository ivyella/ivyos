pragma Singleton
pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.Common
import qs.Notification

Singleton {
    id: root
    property bool visible: false
    property bool settingsExpanded: false
    property bool notificationsExpanded: true

    property int volume: 0
    property int brightness: 0
    property string wifiNetwork: "Disconnected"
    property bool wifiEnabled: false
    property bool bluetoothEnabled: false
    property bool nightLightEnabled: false
    property bool dndEnabled: false

    IpcHandler {
        target: "quickpanel"
        function toggle(): void { root.visible = !root.visible }
    }

    function poll() {
        if (!root.visible) return
        volProc.running = true
        brightGetProc.running = true
        wifiProc.running = true
        btStatusProc.running = true
    }

    onVisibleChanged: if (visible) poll()

    Timer {
        interval: 5000
        running: root.visible
        repeat: true
        onTriggered: root.poll()
    }

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

    function setVolume(val) {
        if (!root.visible) return
        root.volume = val
        const p = Qt.createQmlObject('import Quickshell.Io; Process {}', root)
        p.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", val + "%", "-l", "1.0"]
        p.running = true
    }

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
    }

    function setBrightness(val) {
        if (!root.visible) return
        root.brightness = val
        const p = Qt.createQmlObject('import Quickshell.Io; Process {}', root)
        p.command = ["brightnessctl", "s", val + "%"]
        p.running = true
    }

    Process {
        id: wifiProc
        command: ["nmcli", "-t", "-f", "ACTIVE,SSID", "dev", "wifi"]
        property string _matched: ""
        stdout: SplitParser {
            onRead: data => {
                if (data.startsWith("yes:")) {
                    wifiProc._matched = data.split(":")[1] ?? ""
                }
            }
        }
        onRunningChanged: {
            if (!running) {
                if (_matched !== "") {
                    root.wifiNetwork = _matched
                    root.wifiEnabled = true
                } else {
                    root.wifiNetwork = "Disconnected"
                    root.wifiEnabled = false
                }
                _matched = ""
            }
        }
    }

    Process {
        id: btStatusProc
        command: ["bluetoothctl", "show"]
        stdout: SplitParser {
            onRead: data => {
                if (data.includes("Powered: yes")) root.bluetoothEnabled = true
            }
        }
        onRunningChanged: {
            if (running) root.bluetoothEnabled = false
        }
    }

    PanelWindow {
        visible: root.visible
        WlrLayershell.layer: WlrLayer.Overlay
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
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 40
            anchors.rightMargin: 10
            width: 340
            spacing: 8

            PanelCard {
                title: "Quick Settings"
                icon: "tune"
                isExpanded: root.settingsExpanded
                onHeaderClicked: root.settingsExpanded = !root.settingsExpanded

                Column {
                    width: parent.width
                    spacing: 8
                    visible: root.settingsExpanded

                    RowLayout {
                        width: parent.width
                        spacing: 8
                        ControlTile {
                            Layout.fillWidth: true
                            icon: root.wifiEnabled ? "wifi" : "wifi_off"
                            label: root.wifiEnabled ? root.wifiNetwork : "Wi-Fi Off"
                            active: root.wifiEnabled
                            onToggled: {
                                const cmd = root.wifiEnabled ? "off" : "on"
                                const p = Qt.createQmlObject('import Quickshell.Io; Process {}', root)
                                p.command = ["nmcli", "radio", "wifi", cmd]
                                p.running = true
                                root.wifiEnabled = !root.wifiEnabled
                            }
                        }
                    }

                    RowLayout {
                        width: parent.width
                        spacing: 8
                        ControlTile {
                            Layout.fillWidth: true
                            icon: "bluetooth"
                            label: "Bluetooth"
                            active: root.bluetoothEnabled
                            onToggled: {
                                const cmd = root.bluetoothEnabled ? "off" : "on"
                                const p = Qt.createQmlObject('import Quickshell.Io; Process {}', root)
                                p.command = ["bluetoothctl", "power", cmd]
                                p.running = true
                                root.bluetoothEnabled = !root.bluetoothEnabled
                            }
                        }
                        ControlTile {
                            Layout.fillWidth: true
                            icon: "bedtime"
                            label: "Night Light"
                            active: root.nightLightEnabled
                            onToggled: root.nightLightEnabled = !root.nightLightEnabled
                        }
                    }

                    ControlSlider {
                        width: parent.width
                        icon: root.volume === 0 ? "volume_off" : "volume_up"
                        label: "Volume"
                        value: root.volume
                        onUserChanged: val => root.setVolume(val)
                    }

                    ControlSlider {
                        width: parent.width
                        icon: "brightness_5"
                        label: "Brightness"
                        value: root.brightness
                        onUserChanged: val => root.setBrightness(val)
                    }
                }
            }

            PanelCard {
                title: "Notifications"
                icon: NotiServer.history.length > 0 ? "notifications_unread" : "notifications"
                isExpanded: root.notificationsExpanded
                onHeaderClicked: root.notificationsExpanded = !root.notificationsExpanded
                headerButton: NotiServer.history.length > 0
                headerButtonLabel: "Clear"
                onHeaderButtonClicked: NotiServer.history = []  // fix 1

                ListView {
                    width: parent.width
                    implicitHeight: Math.min(contentHeight, 400)
                    visible: root.notificationsExpanded
                    model: NotiServer.history
                    spacing: 6
                    clip: true
                    delegate: NotificationDelegate {}

                    Text {
                        anchors.centerIn: parent
                        visible: parent.count === 0
                        text: "No notifications"
                        color: Theme.color.fg2
                        font.family: Theme.font.ui
                    }
                }
            }
        }
    }

    component PanelCard: Rectangle {
        property string title: ""
        property string icon: ""
        property bool isExpanded: true
        property bool headerButton: false
        property string headerButtonLabel: ""
        signal headerClicked()
        signal headerButtonClicked()
        default property alias contents: bodyCol.children

        width: parent.width
        implicitHeight: outerCol.implicitHeight + 24
        radius: Theme.radius.md
        color: Theme.color.bg0
        border.color: Theme.color.border0
        border.width: 1

        Behavior on implicitHeight {
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }

        Column {
            id: outerCol
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            RowLayout {
                width: parent.width
                height: 28
                spacing: 8

                MdIcons { text: icon; color: Theme.color.accent0; iconSize: 16; fill: 1 }

                Text {
                    text: title
                    Layout.fillWidth: true
                    color: Theme.color.fg0
                    font.pixelSize: Theme.font.sm
                    font.family: Theme.font.ui
                    font.weight: Font.Medium
                }

                Rectangle {
                    width: 50; height: 22; radius: 11
                    color: clearHover.containsMouse ? Theme.color.accent0 : Theme.color.bg2
                    visible: headerButton
                    Text {
                        anchors.centerIn: parent
                        text: headerButtonLabel
                        color: Theme.color.fg0
                        font.pixelSize: 10
                        font.family: Theme.font.ui
                    }
                    MouseArea {
                        id: clearHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onPressed: (mouse) => mouse.accepted = true
                        onClicked: (mouse) => {
                            mouse.accepted = true
                            headerButtonClicked()
                        }
                    }
                }

                MdIcons {
                    text: isExpanded ? "expand_less" : "expand_more"
                    color: Theme.color.fg2
                    iconSize: 16
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onPressed: (mouse) => mouse.accepted = true
                    onClicked: (mouse) => {
                        mouse.accepted = true
                        headerClicked()
                    }
                }
            }

            Column {
                id: bodyCol
                width: parent.width
                spacing: 8
                clip: true
            }
        }
    }

    component ControlTile: Rectangle {
        property string icon: ""
        property string label: ""
        property bool active: false
        signal toggled()

        height: 50
        radius: Theme.radius.md
        color: active ? Theme.color.accent0 : (tileHover.containsMouse ? Theme.color.bg3 : Theme.color.bg2)
        Behavior on color { ColorAnimation { duration: 150 } }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            MdIcons {
                text: icon
                iconSize: 16
                fill: active ? 1 : 0
                color: active ? Theme.color.bg0 : Theme.color.fg1
            }
            Text {
                text: label
                Layout.fillWidth: true
                color: active ? Theme.color.bg0 : Theme.color.fg0
                font.pixelSize: 11
                font.family: Theme.font.ui
                elide: Text.ElideRight
            }
        }

        MouseArea {
            id: tileHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onPressed: (mouse) => mouse.accepted = true
            onClicked: (mouse) => {
                mouse.accepted = true
                toggled()
            }
        }
    }

    component ControlSlider: Column {
        property string icon: ""
        property string label: ""
        property int value: 0
        signal userChanged(int val)

        width: parent.width
        spacing: 4

        RowLayout {
            width: parent.width
            Text {
                text: label
                color: Theme.color.fg1
                font.pixelSize: 10
                font.family: Theme.font.ui
                Layout.fillWidth: true
            }
            Text {
                text: value + "%"
                color: Theme.color.fg2
                font.pixelSize: 10
                font.family: Theme.font.ui
            }
        }

        Slider {
            width: parent.width
            from: 0
            to: 100
            value: parent.value
            onMoved: userChanged(Math.round(value))
        }
    }

    component NotificationDelegate: Rectangle {
        required property var modelData  // fix 2
        width: ListView.view.width
        height: notifInner.implicitHeight + 16
        color: Theme.color.bg1
        radius: 8
        border.width: 1
        border.color: Theme.color.border0

        Column {
            id: notifInner
            anchors.fill: parent
            anchors.margins: 8
            spacing: 2

            Row {
                width: parent.width
                Text {
                    text: modelData.appName ?? ""
                    color: Theme.color.fg2
                    font.pixelSize: 10
                    font.family: Theme.font.ui
                    width: parent.width - tsText.width
                    elide: Text.ElideRight
                }
                Text {
                    id: tsText
                    text: modelData.timestamp
                        ? Qt.formatDateTime(new Date(Date.parse(modelData.timestamp)), "hh:mm AP")
                        : ""
                    color: Theme.color.fg2
                    font.pixelSize: 10
                    font.family: Theme.font.ui
                }
            }

            Text {
                text: modelData.summary ?? ""
                color: Theme.color.fg0
                font.bold: true
                font.pixelSize: 13
                font.family: Theme.font.ui
                width: parent.width
                wrapMode: Text.WordWrap
            }

            Text {
                text: modelData.body ?? ""
                color: Theme.color.fg1
                font.pixelSize: 11
                font.family: Theme.font.ui
                width: parent.width
                wrapMode: Text.WordWrap
                maximumLineCount: 3
                visible: (modelData.body ?? "") !== ""
            }
        }
    }
}