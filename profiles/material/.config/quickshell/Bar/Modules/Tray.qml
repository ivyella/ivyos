import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs.Bar
import qs.Common

Rectangle {
    id: trayCapsule
    color: Colors.surfaceContainerHigh
    radius: Metrics.radiusLg
    height: Metrics.controlHeightSm
    implicitWidth: trayRow.implicitWidth + Metrics.paddingMd * 2
    property var window

    Row {
        id: trayRow
        spacing: Metrics.spacingSm
        anchors.centerIn: parent

        Repeater {
            model: SystemTray.items
            delegate: Item {
                width: Metrics.iconSize
                height: Metrics.iconSize

                Image {
                    anchors.fill: parent
                    source: modelData.icon
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: mouse => {
                        if (mouse.button === Qt.RightButton && modelData.hasMenu) {
                            const pos = mapToItem(null, mouse.x, mouse.y);
                            modelData.display(trayCapsule.window, pos.x, pos.y);
                        } else if (mouse.button === Qt.LeftButton) {
                            modelData.activate();
                        }
                    }
                }
            }
        }
    }
}