import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs.Bar
import qs.Common

Rectangle {
    id: trayCapsule
    color: Theme.color.surface
    radius: Theme.radius.lg
    height: Theme.height.sm
    implicitWidth: trayRow.implicitWidth + Theme.padding.md * 2
    property var window

    Row {
        id: trayRow
        spacing: Theme.spacing.sm
        anchors.centerIn: parent

        Repeater {
            model: SystemTray.items
            delegate: Item {
                width: Theme.icon.sm
                height: Theme.icon.sm

                Image {
                    anchors.fill: parent
                    source: modelData.icon || Quickshell.iconPath("image-missing", "application-x-executable")
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