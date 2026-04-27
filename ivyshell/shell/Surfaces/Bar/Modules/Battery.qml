import QtQuick
import QtQuick.Layouts
import qs.Reusables.Theme
import qs.Reusables.Components
import qs.Services.Battery

BarCapsule {
    visible: Battery.batteryAvailable

    BarIconBox {
        icon: BarIcon {
            text: Battery.batteryIcon
            color: Battery.isLow && !Battery.isCharging
                ? Theme.color.red0
                : Battery.isCharging
                    ? Theme.color.green1
                    : Theme.color.accent0
            Layout.alignment: Qt.AlignVCenter
        }
    }

    Text {
        text: Battery.batteryLevel
        color: Battery.isLow && !Battery.isCharging
            ? Theme.color.red0
            : Theme.color.fg1
        font.pixelSize: Theme.font.sm
        font.family: Theme.font.ui
        font.weight: Theme.font.normal
        Layout.alignment: Qt.AlignVCenter
    }
}
