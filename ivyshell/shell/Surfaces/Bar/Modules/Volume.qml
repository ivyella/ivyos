import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Reusables.Theme
import qs.Reusables.MdIcons
import qs.Services

Rectangle {
    id: volumeCapsule
    color:         Theme.color.bg2
    radius:        Theme.radius.lg
    height:        Theme.height.sm
    implicitWidth: volumeLayout.implicitWidth + Theme.padding.md

    RowLayout {
        id: volumeLayout
        spacing: Theme.spacing.sm

        Rectangle {
            color:         Theme.color.bg3
            height:        Theme.height.sm
            radius:        Theme.radius.lg
            implicitWidth: volumeIcon.implicitWidth + Theme.padding.sm * 2

            MdIcons {
                id:            volumeIcon
                anchors.centerIn: parent
                text:    Audio.muted || Audio.volume === 0 ? "volume_off"
                       : Audio.volume < 50               ? "volume_down"
                       :                                   "volume_up"
                iconSize: Theme.icon.sm
                color:    Theme.color.accent0
                fill:     1
            }
        }

        Text {
            text:           Audio.volume
            color:          Theme.color.fg1
            font.pixelSize: Theme.font.sm
            font.family:    Theme.font.ui
            font.weight:    Theme.font.normal
        }
    }

    MouseArea {
        anchors.fill: parent
        onWheel: wheel => Audio.adjustVolume(wheel.angleDelta.y > 0 ? 5 : -5)
    }
}