pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.Reusables.Theme
import qs.Reusables.MdIcons
import qs.Reusables.Components
import qs.Services

PanelWindow {
    id: root

    // ── Wayland ───────────────────────────────────────────────────────────────
    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusionMode:               ExclusionMode.Ignore

    anchors.bottom: true
    anchors.left:   true
    anchors.right:  true

    implicitHeight: 80
    color:          "transparent"
    

    // ── Visibility ────────────────────────────────────────────────────────────
    property bool shown: false
    visible: shown  // always present, opacity handles show/hide

    function show() {
        shown = true
        hideTimer.restart()
    }

    function hide() {
        shown = false
    }

    Timer {
        id:       hideTimer
        interval: 2000
        onTriggered: root.hide()
    }

    // ── React to Audio changes ────────────────────────────────────────────────
    Connections {
        target: Audio
        function onVolumeChanged() { root.show() }
        function onMutedChanged()  { root.show() }
    }

    // ── OSD pill ──────────────────────────────────────────────────────────────
    Item {
        anchors.bottom:           parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        // anchors.bottomMargin:     Theme.spacing.lg
        width:                    260
        height:                   56

        opacity: root.shown ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }

        
        anchors.bottomMargin: root.shown
            ? Theme.spacing.lg
            : Theme.spacing.lg - 8
        Behavior on anchors.bottomMargin {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }

        Rectangle {
            anchors.fill: parent
            radius:       Theme.radius.lg
            color:        Theme.color.bg0
            border.color: Theme.color.border0
            border.width: 0
        }

        Row {
            anchors.fill:    parent
            anchors.margins: Theme.spacing.md
            spacing:         Theme.spacing.sm

            // ── Mute toggle icon ──────────────────────────────────────────────
            Rectangle {
                width:   32
                height:  32
                radius:  16
                color:   muteArea.containsMouse ? Theme.color.bg3 : "transparent"
                anchors.verticalCenter: parent.verticalCenter

                Behavior on color { ColorAnimation { duration: 100 } }

                MdIcons {
                    anchors.centerIn: parent
                    text:     Audio.muted || Audio.volume === 0 ? "volume_off"
                            : Audio.volume < 50                 ? "volume_down"
                            :                                    "volume_up"
                    iconSize: Theme.icon.lg
                    color:    Theme.color.accent0
                    fill:     1
                }

                MouseArea {
                    id:           muteArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    Audio.toggleMute()
                }
            }

            // ── Slider ────────────────────────────────────────────────────────
            ControlSlider {
                showLabel: false
                width:                  parent.width - 32 - parent.spacing - Theme.spacing.md
                anchors.verticalCenter: parent.verticalCenter
                label:                  ""
                icon:                   ""
                value:                  Audio.volume
                onUserChanged:          val => Audio.setVolume(val)
            }
        }
    }
}