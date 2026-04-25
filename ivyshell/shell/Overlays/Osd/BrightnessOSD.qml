pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Reusables.Theme
import qs.Reusables.MdIcons
import qs.Reusables.Components
import qs.Services

PanelWindow {
    id: root

    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusionMode:               ExclusionMode.Ignore

    anchors.bottom: true
    anchors.left:   true
    anchors.right:  true

    implicitHeight: 80
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
        interval: 2000
        onTriggered: root.hide()
    }

    Connections {
        target: Brightness
        function onLevelChanged() { root.show() }
    }

    Item {
        anchors.bottom:           parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        property real bottomOffset: root.shown ? Theme.spacing.lg : Theme.spacing.lg - 8
        anchors.bottomMargin: bottomOffset
        Behavior on bottomOffset {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }

        width:  260
        height: 56

        opacity: root.shown ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }

        Rectangle {
            anchors.fill: parent
            radius:       Theme.radius.lg
            color:        Theme.color.bg0
            border.color: Theme.color.border0
            border.width: 1
        }

        Row {
            anchors.fill:         parent
            anchors.leftMargin:   Theme.spacing.md
            anchors.rightMargin:  Theme.spacing.md
            anchors.topMargin:    Theme.spacing.md
            anchors.bottomMargin: Theme.spacing.md
            spacing:              Theme.spacing.sm

            Rectangle {
                width:   32
                height:  32
                radius:  16
                color:   "transparent"
                anchors.verticalCenter: parent.verticalCenter

                MdIcons {
                    anchors.centerIn: parent
                    text:     Brightness.level < 30 ? "brightness_low"
                            : Brightness.level < 70 ? "brightness_medium"
                            :                         "brightness_high"
                    iconSize: Theme.icon.sm
                    color:    Theme.color.accent0
                    fill:     1
                }
            }

            ControlSlider {
                width:                  parent.width - 32 - parent.spacing - Theme.spacing.md
                anchors.verticalCenter: parent.verticalCenter
                label:                  ""
                icon:                   ""
                showLabel:              false
                value:                  Brightness.level
                onUserChanged:          val => Brightness.setLevel(val)
            }
        }
    }
}