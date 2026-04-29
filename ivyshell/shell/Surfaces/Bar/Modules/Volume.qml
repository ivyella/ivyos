import QtQuick
import QtQuick.Layouts
import qs.Reusables.Theme
import qs.Reusables.Components
import qs.Services

BarCapsule {
    BarIconBox {
        icon: BarIcon {
            text: Audio.muted || Audio.volume === 0 ? "volume_off"
                : Audio.volume < 50               ? "volume_down"
                :                                   "volume_up"
            Layout.alignment: Qt.AlignVCenter
        }

    }
    Text {
        text: Audio.volume
        color: Theme.color.fg1
        font.pixelSize: Theme.font.sm
        font.family: Theme.font.ui
        font.weight: Theme.font.normal
        Layout.alignment: Qt.AlignVCenter
    }
    mouseArea {
        enabled: true
        onWheel: wheel => Audio.adjustVolume(wheel.angleDelta.y > 0 ? 5 : -5)
    }
}