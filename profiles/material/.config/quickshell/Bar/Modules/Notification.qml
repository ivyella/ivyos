import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.Bar
import qs.Common

Rectangle {
    id: notificationButton
    color: Colors.surfaceContainerHigh
    radius: Metrics.radiusLg
    height: Metrics.controlHeightSm
    implicitWidth: notificationButtonText.implicitWidth + Metrics.paddingMd * 2

     RowLayout {
        id: notificationButtonText
        anchors.centerIn: parent
        spacing: Metrics.spacingSm

        Text {
            id: notificationButtonIcon
            text: "="
            color: Config.fontColorPrimary
            font.pixelSize: Config.fontSizeNormal
            font.family: Config.fontFamily
            font.weight: 600
        }
        Text {
            id: notificationButtonCount
            text: "="
            color: Config.fontColorSecondary
            font.pixelSize: Config.fontSizeNormal
            font.family: Config.fontFamily
            font.weight: 600
        }

    }
}