import QtQuick
import QtQuick.Layouts
import qs.Reusables.Theme
import qs.Reusables.Components
import qs.Services

BarCapsule {
    visible: Weather.ready

    BarIconBox {
        icon: BarIcon {
            text: Weather.icon
            Layout.alignment: Qt.AlignVCenter
        }
    }

    Text {
        text: Weather.feelsLike + Weather.unitSymbol
        color: Theme.color.fg1
        font.pixelSize: Theme.font.sm
        font.family: Theme.font.ui
        font.weight: Theme.font.normal
        Layout.alignment: Qt.AlignVCenter
    }

    mouseArea {
        enabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Weather.toggleUnit()
    }
}