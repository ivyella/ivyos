import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import qs.Bar

Capsule {
    width: trayRow.implicitWidth + Config.capsuleMargin

    Row {
        id: trayRow
        spacing: 10
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 9

        Repeater {
            model: SystemTray.items
            delegate: Item {
                width: 14
                height: 14

                Image {
                    anchors.fill: parent
                    source: modelData.icon
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (mouse.button === Qt.RightButton && modelData.hasMenu) {
                            modelData.display(trayBackground, mouse.x, mouse.y);
                        } else if (mouse.button === Qt.LeftButton) {
                            modelData.activate();
                        }
                    }
                }
            }
        }
    }
}
