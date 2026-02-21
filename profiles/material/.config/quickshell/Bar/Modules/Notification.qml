import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.Bar
import qs.Common
import qs.Notification
import qs.NotificationHistory

Rectangle {
    id: notificationButton
    // Change color based on whether the panel is open or the button is hovered
    color: NotificationHistory.shown ? Colors.primaryContainer : 
           (mouseArea.containsMouse ? Theme.color.surfaceMid : Theme.color.surface)
    
    radius: Theme.radius.lg
    height: Theme.height.sm
    implicitWidth: notificationButtonLayout.implicitWidth + Theme.padding.md * 2
    
    Behavior on color { ColorAnimation { duration: 150 } }

    RowLayout {
        id: notificationButtonLayout
        anchors.centerIn: parent
        spacing: Theme.spacing.sm

        Text {
            id: notificationButtonIcon
            text: "󰂚" // Changed to a notification bell icon (Nerd Font)
            color: NotificationHistory.shown ? Theme.color.text : Theme.color.text
            font.pixelSize: Theme.font.sm
            font.family: Theme.font.ui
            font.weight: Theme.font.normal
        }

        // Show the count of notifications in the history
        Text {
            id: notificationButtonCount
            text: NotiServer.history.length > 0 ? NotiServer.history.length : ""
            visible: text !== ""
            color: NotificationHistory.shown ? Theme.color.subtext : Theme.color.subtext
            font.pixelSize: Theme.font.sm
            font.family: Theme.font.ui
            font.weight: Theme.font.normal
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        // This is the magic line that launches your panel
        onClicked: NotificationHistory.toggle()
    }
}