import QtQuick
import QtQuick.Layouts
import qs.Reusables.Theme
import qs.Reusables.Components
import qs.Services

BarCapsule {
    BarIconBox {
        icon: BarIcon {
            text: Network.icon
            Layout.alignment: Qt.AlignVCenter
        }
    }

    Text {
        text: Network.label
        color: Theme.color.fg1
        font.pixelSize: Theme.font.sm
        font.family: Theme.font.ui
        font.weight: Theme.font.normal
        Layout.alignment: Qt.AlignVCenter
    }
}