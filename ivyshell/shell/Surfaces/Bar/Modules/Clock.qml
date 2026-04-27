import QtQuick
import QtQuick.Layouts
import qs.Reusables.Theme
import qs.Reusables.Components
import qs.Services.Time

BarCapsule {
    BarIconBox {
        icon: Text {
            anchors.centerIn: parent
            text: Clock.currentTime
            color: Theme.color.fg0
            font.pixelSize: Theme.font.sm
            font.family: Theme.font.ui
            font.weight: Theme.font.normal
        }
    }

    Text {
        text: Clock.currentDate
        color: Theme.color.fg1
        font.pixelSize: Theme.font.sm
        font.family: Theme.font.ui
        font.weight: Theme.font.normal
        Layout.alignment: Qt.AlignVCenter
    }
}
