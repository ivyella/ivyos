import QtQuick
import QtQuick.Layouts
import qs.Reusables.Theme
import qs.Reusables.MdIcons
import qs.Services

Rectangle {
    color: Theme.color.bg2
    radius: Theme.radius.lg

    height: Theme.height.sm

    // IMPORTANT: makes outer padding predictable
    implicitWidth: row.implicitWidth + Theme.spacing.sm * 2

    Row {
        id: row
        spacing: Theme.spacing.sm
        anchors.verticalCenter: parent.verticalCenter

        // ── ICON BOX ───────────────────────────────────────────────
        Rectangle {
            visible: WindowService.activeAppId !== ""
            color: Theme.color.bg3
            radius: Theme.radius.lg

            height: Theme.height.sm

            // consistent padding model
            width: Theme.height.sm

            // center content properly
            Item {
                anchors.fill: parent
                anchors.margins: Theme.spacing.xs

                Image {
                    id: iconImg

                    width: Theme.icon.sm
                    height: Theme.icon.sm

                    anchors.centerIn: parent

                    source: WindowService.iconFor(WindowService.activeAppId)

                    // IMPORTANT: match actual render size
                    sourceSize: Qt.size(Theme.icon.sm * 2, Theme.icon.sm * 2)

                    fillMode: Image.PreserveAspectFit

                    asynchronous: true
                    smooth: true

                    visible: status === Image.Ready
                }

                Text {
                    anchors.centerIn: parent

                    visible: iconImg.status !== Image.Ready

                    text: WindowService.activeAppId
                        ? WindowService.activeAppId.charAt(0).toUpperCase()
                        : "?"

                    color: Theme.color.accent0
                    font.pixelSize: Theme.font.sm
                    font.family: Theme.font.ui
                }
            }
        }

        // ── WINDOW TEXT ────────────────────────────────────────────
        Text {
            anchors.verticalCenter: parent.verticalCenter

            text: WindowService.activeWindow

            color: Theme.color.fg0
            font.pixelSize: Theme.font.sm
            font.family: Theme.font.ui
            font.weight:    Theme.font.normal
            // IMPORTANT: prevents overflow affecting layout
            elide: Text.ElideRight
            maximumLineCount: 1
        }
    }
}