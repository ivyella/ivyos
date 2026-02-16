import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.Bar
import qs.Common

Rectangle {
    color: Colors.surfaceContainerHigh
    radius: Metrics.radiusLg
    height: Metrics.controlHeightSm
    implicitWidth: clockLayout.implicitWidth + Metrics.paddingMd * 2

    RowLayout {
        id: clockLayout
        anchors.centerIn: parent
        spacing: Metrics.spacingSm

        Text {
            id: timeText
            text: Qt.formatDateTime(new Date(), "hh:mm AP")
            color: Config.fontColorPrimary
            font.pixelSize: Config.fontSizeNormal
            font.family: Config.fontFamily
            font.weight: 600
        }
        Text {
            id: dateText
            text: Qt.formatDateTime(new Date(), "ddd, MMM dd")
            color: Config.fontColorSecondary
            font.pixelSize: Config.fontSizeNormal
            font.family: Config.fontFamily
            font.weight: 600
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
