import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.Reusables.Theme
import qs.Reusables.MdIcons


Rectangle {
    color: Theme.color.bg2
    radius: Theme.radius.lg
    height: Theme.height.sm
    implicitWidth: clockLayout.implicitWidth + Theme.padding.md

    RowLayout {
        id: clockLayout
        spacing: Theme.spacing.md

        Rectangle {
            id: timeTextBackdrop
            color: Theme.color.bg3
            width: timeText.iconSize
            height: Theme.height.sm
            radius: Theme.radius.lg  // optional, if you want it round
            implicitWidth: timeText.implicitWidth + Theme.padding.sm * 2
            Text {
                id: timeText
                anchors.centerIn: parent
                text: Qt.formatDateTime(new Date(), "hh:mm AP")
                color: Theme.color.fg0
                font.pixelSize: Theme.font.sm
                font.family: Theme.font.ui
                font.weight: Theme.font.normal
            }
        }    
        Text {
            id: dateText
            text: Qt.formatDateTime(new Date(), "ddd, MMM dd")
            color: Theme.color.fg1
            font.pixelSize: Theme.font.sm
            font.family: Theme.font.ui
            font.weight: Theme.font.normal
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            timeText.text = Qt.formatDateTime(new Date(), "hh:mm AP");
            dateText.text = Qt.formatDateTime(new Date(), "ddd, MMM dd");
        }
    }
}
