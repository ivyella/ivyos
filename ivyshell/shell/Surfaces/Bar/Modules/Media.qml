import QtQuick
import QtQuick.Layouts
import qs.Reusables.Theme
import qs.Reusables.MdIcons
import qs.Services

Rectangle {
    color:         Theme.color.bg2
    radius:        Theme.radius.lg
    height:        Theme.height.sm
    implicitWidth: mprisLayout.implicitWidth + Theme.padding.md
    visible:       Media.hasPlayer

    RowLayout {
        id: mprisLayout
        spacing: Theme.spacing.sm

        Rectangle {
            visible:       Media.isSpotify
            color:         Theme.color.bg3
            height:        Theme.height.sm
            radius:        Theme.radius.lg
            implicitWidth: spotifyIcon.implicitWidth + Theme.padding.sm * 2
            MdIcons {
                id:               spotifyIcon
                anchors.centerIn: parent
                text:             "music_note"
                iconSize:         Theme.icon.sm
                color:            Theme.color.accent0
                fill:             1
            }
        }

        Rectangle {
            visible:       Media.isFirefox
            color:         Theme.color.bg3
            height:        Theme.height.sm
            radius:        Theme.radius.lg
            implicitWidth: firefoxIcon.implicitWidth + Theme.padding.sm * 2
            MdIcons {
                id:               firefoxIcon
                anchors.centerIn: parent
                text:             "language"
                iconSize:         Theme.icon.sm
                fill:             1
            }
        }

        Text {
            text:           Media.title
            color:          Theme.color.fg0
            font.pixelSize: Theme.font.sm
            font.family:    Theme.font.ui
            font.weight:    Theme.font.normal
        }

        Text {
            text:           "•"
            color:          Theme.color.accent0
            font.pixelSize: Theme.font.sm
            font.family:    Theme.font.ui
        }

        Text {
            text:           Media.artist
            color:          Theme.color.fg1
            font.pixelSize: Theme.font.sm
            font.family:    Theme.font.ui
            font.weight:    Theme.font.light
        }
    }

    MouseArea {
        anchors.fill:    parent
        acceptedButtons: Qt.LeftButton
        onClicked:       Media.togglePlaying()
        onWheel: wheel => {
            if (wheel.angleDelta.y > 0) Media.next()
            else                        Media.previous()
        }
    }
}