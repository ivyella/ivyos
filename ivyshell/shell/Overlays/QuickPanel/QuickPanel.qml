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
import qs.Services.Notification
import qs.Reusables.Components
import qs.Services

Singleton {
    id: root

    // ── visibility ────────────────────────────────────────────────────────────
    property bool visible: false

    // ── accordion state ───────────────────────────────────────────────────────
    property bool settingsExpanded:      true
    property bool notificationsExpanded: true
    // ── interaction debounce (brightness/wifi/bt only) ────────────────────────
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



Rectangle {
    id: card

    property string title:             ""
    property string icon:              ""
    property bool   isExpanded:        true
    property bool   headerButton:      false
    property string headerButtonLabel: ""
    signal headerClicked()
    signal headerButtonClicked()
    default property alias contents: bodyCol.children

    implicitHeight: headerRow.height
                    + (isExpanded ? bodyCol.implicitHeight + 20 : 0)
                    + 20
    radius:       Theme.radius.lg
    color:        Theme.color.bg0
    border.color: Theme.color.border0
    border.width: 1
    clip:         true

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
                    text:             card.headerButtonLabel
                    color:            clearHover.containsMouse
                                      ? Theme.color.bg0
                                      : Theme.color.fg1
                    font.pixelSize:   10
                    font.family:      Theme.font.ui
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
    IpcHandler {
        target: "quickpanel"
        function toggle(): void { root.visible = !root.visible }
    }

    // ── polling ───────────────────────────────────────────────────────────────
    function poll() {
        if (!root.visible || root._userInteracting) return
        brightGetProc.running = true
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
                        icon:      Network.icon
                        label:     Network.label
                        active:    Network.enabled
                        onToggled: Network.toggle()
                    }

                    ControlTile {
                        Layout.fillWidth: true
                        icon:      "bluetooth"
                        label:     Bluetooth.connectedDevice !== "" ? Bluetooth.connectedDevice : "Bluetooth"
                        active:    Bluetooth.enabled
                        visible:   Bluetooth.available
                        onToggled: Bluetooth.toggle()
                    }

                    ControlTile {
                        Layout.fillWidth: true
                        icon:      root.nightLightEnabled ? "bedtime" : "bedtime_off"
                        label:     "Night Light"
                        active:    NightLight.enabled
                        onToggled: NightLight.toggle()
                    }
                    ControlTile {
                        Layout.fillWidth: true
                        icon:      NotiServer.dnd ? "notifications_off" : "notifications"
                        label:     "Do Not Disturb"
                        active:    NotiServer.dnd
                        onToggled: NotiServer.dnd = !NotiServer.dnd
                    }
                }

                ControlSlider {
                    width:         parent.width
                    icon:          Audio.muted || Audio.volume === 0 ? "volume_off" : "volume_up"
                    label:         "Volume"
                    value:         Audio.volume
                    onUserChanged: val => Audio.setVolume(val)
                }

                ControlSlider {
                    width:         parent.width
                    icon:          "brightness_5"
                    label:         "Brightness"
                    value:         Brightness.level
                    visible:       Brightness.available
                    onUserChanged: val => Brightness.setLevel(val)
                }
            }

            // ── Notifications card ────────────────────────────────────────────
            PanelCard {
                title:             "Notifications"
                icon:              NotiServer.history.length > 0 ? "notifications_unread" : "notifications"
                isExpanded:        root.notificationsExpanded
                onHeaderClicked:   root.notificationsExpanded = !root.notificationsExpanded
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

    component SectionLabel: Text {
        color:              Theme.color.fg2
        font.pixelSize:     9
        font.family:        Theme.font.ui
        font.weight:        Font.Medium
        font.letterSpacing: 0.8
        topPadding:         4
    }

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