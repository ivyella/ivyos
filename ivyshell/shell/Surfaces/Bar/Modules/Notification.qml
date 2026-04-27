import QtQuick
import qs.Reusables.Theme
import qs.Reusables.Components
import qs.Services.Notification
import qs.Overlays.QuickPanel

BarIconBox {
    property bool active: QuickPanel.visible

    color: active ? Theme.color.accent0 : (mouseArea.containsMouse ? Theme.color.accent0 : Theme.color.bg3)

    Behavior on color { ColorAnimation { duration: 150 } }

    icon: BarIcon {
        text: NotiServer.dnd ? "notifications_off"
            : NotiServer.history.length > 0 ? "notifications_unread"
            : "notifications"
        color: mouseArea.containsMouse || active ? Theme.color.bg3 : Theme.color.accent0
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: QuickPanel.toggle()
    }
}