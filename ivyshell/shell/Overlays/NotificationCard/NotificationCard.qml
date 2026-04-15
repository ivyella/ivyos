import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.Overlays
import qs.Reusables
import qs.Surfaces
import qs.Services

Rectangle {
    id: notifyItem
    required property var modelData

    implicitWidth: ListView.view ? ListView.view.width : 360
    implicitHeight: fullLayout.implicitHeight + 20
    color: dismissArea.containsMouse ? Theme.color.bg2 : Theme.color.bg0

    border.width: 1
    border.color: Theme.color.border0
    radius: 12

    Timer {
        id: dismissTimer
        interval: 5000
        running: true
        onTriggered: notifyItem.modelData.expire()
    }

    RowLayout {
        id: fullLayout
        anchors.margins: 10
        anchors.fill: parent
        spacing: 10

        Rectangle {
            id: notiIcon
            radius: 10
            implicitWidth: 48
            implicitHeight: 48
            color: "transparent"
            clip: true
            visible: notifyItem.modelData.image !== ""

            IconImage {
                source: notifyItem.modelData.image
                visible: notifyItem.modelData.image !== ""
                implicitSize: 48
                asynchronous: true
                anchors.fill: parent
            }
        }

        ColumnLayout {
            id: textLayout
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Text {
                id: summary
                text: notifyItem.modelData.summary
                font.bold: true
                font.pixelSize: 16
                font.family: "Noto Serif"
                color: Theme.color.fg0
                elide: Text.ElideRight
                Layout.fillWidth: true
                onTextChanged: dismissTimer.restart()
            }

            Text {
                text: notifyItem.modelData.body
                font.pixelSize: 14
                font.family: "Noto Serif"
                color: Theme.color.fg1
                maximumLineCount: 2
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }
    }

    MouseArea {
        id: dismissArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        onClicked: notifyItem.modelData.dismiss()
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
    }
}
