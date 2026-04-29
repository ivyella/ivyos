import QtQuick
import qs.Reusables.Theme
import qs.Reusables.Components
import qs.Surfaces.Settings

BarIconBox {
    id: root
    property bool active: Settings.visible

    // Use the 'hovered' alias from the base component
    color: active || hovered ? Theme.color.accent0 : Theme.color.bg3

    Behavior on color { ColorAnimation { duration: 150 } }

    icon: BarIcon {
        text: "settings"
        color: root.hovered || active ? Theme.color.bg3 : Theme.color.accent0
    }

    // Connect to the signal defined in BarIconBox
    onClicked: Settings.visible = !Settings.visible
}