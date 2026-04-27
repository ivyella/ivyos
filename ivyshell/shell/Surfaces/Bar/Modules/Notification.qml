import QtQuick
import QtQuick.Layouts
import qs.Reusables.Theme
import qs.Reusables.Components
import qs.Services.Notification
import qs.Overlays.QuickPanel

BarCapsule {
    property bool active: QuickPanel.visible

    color: active ? Theme.color.accent0 : (mouseArea.containsMouse ? Theme.color.accent0 : Theme.color.bg3)

    Behavior on color { ColorAnimation { duration: 150 } }

    BarIcon {
        text: NotiServer.dnd ? "notifications_off"
            : NotiServer.history.length > 0 ? "notifications_unread"
            : "notifications"
        color: mouseArea.containsMouse || active ? Theme.color.bg3 : Theme.color.accent0
        Layout.alignment: Qt.AlignVCenter
    }

    mouseArea {
        enabled: true
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: QuickPanel.toggle()
    }
}