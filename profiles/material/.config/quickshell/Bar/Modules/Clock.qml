import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.Bar
import qs.Common

Rectangle {
    color: Theme.color.surface
    radius: Theme.radius.lg
    height: Theme.height.sm
    implicitWidth: clockLayout.implicitWidth + Theme.padding.md * 2

    RowLayout {
        id: clockLayout
        anchors.centerIn: parent
        spacing: Theme.spacing.sm

        Text {
            id: timeText
            text: Qt.formatDateTime(new Date(), "hh:mm AP")
            color: Theme.color.text
            font.pixelSize: Theme.font.sm
            font.family: Theme.font.ui
            font.weight: Theme.font.normal
        }
        Text {
            id: dateText
            text: Qt.formatDateTime(new Date(), "ddd, MMM dd")
            color: Theme.color.subtext
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
