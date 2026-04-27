import QtQuick
import QtQuick.Layouts
import qs.Reusables.Theme
import qs.Reusables.Components
import qs.Services

BarCapsule {
    visible: Media.hasPlayer

    BarIconBox {
        visible: Media.isSpotify
        icon: BarIcon {
            text: "music_note"
            Layout.alignment: Qt.AlignVCenter
        }
    }

    BarIconBox {
        visible: Media.isFirefox
        icon: BarIcon {
            text: "language"
            Layout.alignment: Qt.AlignVCenter
        }
    }

    Text {
        text: Media.title
        color: Theme.color.fg0
        font.pixelSize: Theme.font.sm
        font.family: Theme.font.ui
        font.weight: Theme.font.normal
        Layout.alignment: Qt.AlignVCenter
    }

    Text {
        text: "•"
        color: Theme.color.accent0
        font.pixelSize: Theme.font.sm
        font.family: Theme.font.ui
        Layout.alignment: Qt.AlignVCenter
    }

    Text {
        text: Media.artist
        color: Theme.color.fg1
        font.pixelSize: Theme.font.sm
        font.family: Theme.font.ui
        font.weight: Theme.font.light
        Layout.alignment: Qt.AlignVCenter
    }

    mouseArea {
        enabled: true
        acceptedButtons: Qt.LeftButton
        onClicked: Media.togglePlaying()
        onWheel: wheel => {
            if (wheel.angleDelta.y > 0) Media.next()
            else Media.previous()
        }
    }
}