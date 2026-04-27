import QtQuick
import QtQuick.Layouts
import qs.Reusables.Theme
import qs.Reusables.Components
import qs.Services

BarCapsule {
    BarIconBox {
        visible: WindowService.activeAppId !== ""

        icon: Item {
            width: Theme.icon.sm
            height: Theme.icon.sm
            anchors.centerIn: parent

            Image {
                id: iconImg
                width: Theme.icon.sm
                height: Theme.icon.sm
                anchors.centerIn: parent
                source: WindowService.iconFor(WindowService.activeAppId)
                sourceSize: Qt.size(Theme.icon.sm * 2, Theme.icon.sm * 2)
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                smooth: true
                visible: status === Image.Ready
            }

            Text {
                anchors.centerIn: parent
                visible: iconImg.status !== Image.Ready
                text: WindowService.activeAppId ? WindowService.activeAppId.charAt(0).toUpperCase() : "?"
                color: Theme.color.accent0
                font.pixelSize: Theme.font.sm
                font.family: Theme.font.ui
            }
        }
    }

    Text {
        text: WindowService.activeWindow
        color: Theme.color.fg0
        font.pixelSize: Theme.font.sm
        font.family: Theme.font.ui
        font.weight: Theme.font.normal
        elide: Text.ElideRight
        maximumLineCount: 1
        Layout.alignment: Qt.AlignVCenter
    }
}