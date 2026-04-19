import QtQuick
import Quickshell
import qs.Reusables.Theme
import qs.Reusables.MdIcons
import qs.Surfaces.Settings

Rectangle {
    id: settingsButton
    color: Settings.visible ? Theme.color.accent0 : (hover.containsMouse ? Theme.color.accent0 : Theme.color.bg3)
    radius: Theme.radius.lg
    height: Theme.height.sm
    implicitWidth: settingsIcon.implicitWidth + Theme.padding.sm * 2

    Behavior on color { ColorAnimation { duration: 150 } }

    MdIcons {
        id: settingsIcon
        anchors.centerIn: parent
        text: "settings"
        iconSize: Theme.icon.sm
        color: hover.containsMouse || Settings.visible ? Theme.color.bg3 : Theme.color.accent0
        fill: 1
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Settings.visible = !Settings.visible
    }
}