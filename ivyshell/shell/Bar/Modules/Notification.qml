import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.Bar
import qs.Common
import qs.Notification
import qs.NotificationHistory

Rectangle {
    id: notificationButton
    color: NotificationHistory.historyVisible ? Theme.color.accent0 : 
               (mouseArea.containsMouse ? Theme.color.accent0 : Theme.color.bg3)
    radius: Theme.radius.lg
    height: Theme.height.sm
    implicitWidth: notificationButtonIcon.implicitWidth + Theme.padding.sm * 2

    Behavior on color { ColorAnimation { duration: 150 } }

    MdIcons {
        id: notificationButtonIcon
        anchors.centerIn: parent
        text: NotiServer.history.length > 0 ? "notifications_unread" : "notifications"
        iconSize: Theme.icon.sm
        color: mouseArea.containsMouse || NotificationHistory.historyVisible
            ? Theme.color.bg3
            : Theme.color.accent0
        fill: 1
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: NotificationHistory.historyVisible = !NotificationHistory.historyVisible
    }
}