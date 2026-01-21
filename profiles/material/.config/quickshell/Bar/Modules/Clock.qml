import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.Bar

Capsule {
    width: clockLayout.implicitWidth + Config.capsuleMargin

    RowLayout {
        id: clockLayout
        anchors.centerIn: parent
        Text {
            id: timeText
            text: Qt.formatDateTime(new Date(), "hh:mm AP")
            color: Config.fontColorPrimary
            font.pixelSize: Config.fontSizeNormal
            font.family: Config.fontFamily
            font.bold: true
        }
        Text {
            id: dateText
            text: Qt.formatDateTime(new Date(), "ddd, MMM dd")
            color: Config.fontColorSecondary
            font.pixelSize: Config.fontSizeNormal
            font.family: Config.fontFamily
            font.bold: false
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
