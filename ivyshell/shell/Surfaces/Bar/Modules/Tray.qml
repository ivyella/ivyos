import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.Reusables.Theme
import qs.Reusables.Components
import qs.Overlays.TrayMenu

Rectangle {
    color: Theme.color.bg2
    radius: Theme.radius.lg
    height: Theme.height.sm
    implicitWidth: trayRow.implicitWidth + Theme.padding.md * 2

    Row {
        id: trayRow
        spacing: Theme.spacing.sm
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Theme.padding.sm

        Repeater {
            model: SystemTray.items

            delegate: Item {
                id: trayIcon
                required property var modelData
                width: Theme.icon.sm
                height: Theme.icon.sm

                property string iconSource: {
                    const icon = modelData.icon
                    if (typeof icon === 'string' || icon instanceof String) {
                        if (icon === "") return ""
                        if (icon.includes("?path=")) {
                            const split = icon.split("?path=")
                            if (split.length !== 2) return icon
                            const name = split[0]
                            const path = split[1]
                            const fileName = name.substring(name.lastIndexOf("/") + 1)
                            return `file://${path}/${fileName}`
                        }
                        if (icon.startsWith("/") && !icon.startsWith("file://"))
                            return `file://${icon}`
                        return icon
                    }
                    return ""
                }

                IconImage {
                    id: iconImg
                    anchors.fill: parent
                    source: trayIcon.iconSource !== "" ? trayIcon.iconSource : trayIcon.modelData.icon
                    implicitSize: Theme.icon.sm
                    asynchronous: true
                    smooth: true
                    visible: status === Image.Ready || status === Image.Loading
                }

                // fallback: first letter of app id
                Rectangle {
                    anchors.fill: parent
                    visible: iconImg.status === Image.Error || iconImg.status === Image.Null
                    color: Theme.color.bg3
                    radius: Theme.radius.xs

                    Text {
                        anchors.centerIn: parent
                        text: {
                            const id = trayIcon.modelData.id ?? ""
                            return id ? id.charAt(0).toUpperCase() : "?"
                        }
                        color: Theme.color.fg1
                        font.pixelSize: Theme.font.xs
                        font.family: Theme.font.ui
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: (mouse) => {
                        if (mouse.button === Qt.RightButton && trayIcon.modelData.hasMenu) {
                            const global = trayIcon.mapToGlobal(trayIcon.width / 2, trayIcon.height)
                            if (TrayMenu.visible && TrayMenu.menu === trayIcon.modelData.menu) {
                                TrayMenu.close()
                            } else {
                                TrayMenu.open(trayIcon.modelData.menu, global.x, global.y)
                            }
                        } else if (mouse.button === Qt.LeftButton) {
                            TrayMenu.close()
                            trayIcon.modelData.activate()
                        }
                    }
                }
            }
        }
    }
}
