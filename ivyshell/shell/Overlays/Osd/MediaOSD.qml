pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Reusables.Theme
import qs.Reusables.MdIcons
import qs.Services

PanelWindow {
    id: root
    
    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusionMode:               ExclusionMode.Ignore

    anchors.top: true
    anchors.left:   true
    anchors.right:  true
    margins.top: Theme.height.bar + Theme.spacing.md
    implicitHeight: 100
    color:          "transparent"

    property bool shown: false
    visible: shown

    function show() {
        shown = true
        hideTimer.restart()
    }

    function hide() { shown = false }

    Timer {
        id:       hideTimer
        interval: 3000
        onTriggered: root.hide()
    }

    // ── Trigger on track/state changes ────────────────────────────────────────
    Connections {
        target: Media
        function onTitleChanged()         { root.show() }
        function onArtistChanged()        { root.show() }
        function onPlaybackStateChanged() { root.show() }
    }

    // ── OSD pill ──────────────────────────────────────────────────────────────
    Item {
        anchors.top:           parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        property real topOffset: root.shown ? Theme.spacing.lg : Theme.spacing.lg
        anchors.topMargin: 0
        Behavior on topOffset {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }

        width:   320
        height:  64
        opacity: root.shown ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }

        Rectangle {
            anchors.fill: parent
            radius:       Theme.radius.lg
            color:        Theme.color.bg0
            border.color: Theme.color.border0
            border.width: 0
        }

        Row {
            anchors.fill:         parent
            anchors.leftMargin:   Theme.spacing.md
            anchors.rightMargin:  Theme.spacing.md
            anchors.topMargin:    Theme.spacing.md
            anchors.bottomMargin: Theme.spacing.md
            spacing:              Theme.spacing.md

            // ── Album art / play-pause button ─────────────────────────────────
            Rectangle {
                width:   40
                height:  40
                radius:  Theme.radius.md
                color:   Theme.color.bg2
                anchors.verticalCenter: parent.verticalCenter

                // album art if available
                Image {
                    id:           albumArt
                    anchors.fill: parent
                    source:       Media.artUrl ?? ""
                    fillMode:     Image.PreserveAspectCrop
                    visible:      status === Image.Ready
                    layer.enabled: true
                    layer.effect: null
                    smooth:       true
                    asynchronous: true
                }

                // fallback icon when no art
                MdIcons {
                    anchors.centerIn: parent
                    visible:  albumArt.status !== Image.Ready
                    text:     Media.isPlaying ? "pause" : "play_arrow"
                    iconSize: Theme.icon.md
                    color:    Theme.color.accent0
                    fill:     1
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    Media.togglePlaying()
                }
            }

            // ── Track info ────────────────────────────────────────────────────
            Column {
                anchors.verticalCenter: parent.verticalCenter
                width:   parent.width - 40 - Theme.spacing.md
                spacing: 2

                Text {
                    width:          parent.width
                    text:           Media.title || "No Track"
                    color:          Theme.color.fg0
                    font.pixelSize: Theme.font.md
                    font.family:    Theme.font.ui
                    font.weight:    Font.Medium
                    elide:          Text.ElideRight
                }

                Text {
                    width:          parent.width
                    text:           Media.artist || "Unknown Artist"
                    color:          Theme.color.fg1
                    font.pixelSize: Theme.font.sm
                    font.family:    Theme.font.ui
                    elide:          Text.ElideRight
                }
            }
        }
    }
}