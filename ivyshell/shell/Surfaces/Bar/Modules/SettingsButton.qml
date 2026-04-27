import QtQuick
import qs.Reusables.Theme
import qs.Reusables.Components
import qs.Surfaces.Settings

BarCapsule {
    property bool active: Settings.visible

    color: active ? Theme.color.accent0 : (mouseArea.containsMouse ? Theme.color.accent0 : Theme.color.bg3)

    Behavior on color { ColorAnimation { duration: 150 } }

    BarIconBox {
        icon: BarIcon {
            text: "settings"
            color: mouseArea.containsMouse || active ? Theme.color.bg3 : Theme.color.accent0
        }
    }

    mouseArea {
        enabled: true
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Settings.visible = !Settings.visible
    }
}