pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.Bar
import qs.Bar.Modules

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        id: root
        required property var modelData
        screen: modelData

        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: 30
        color: Config.backgroundColor

        // ───── Base layout: LEFT + RIGHT only ─────
        RowLayout {
            id: edgeLayout
            anchors.fill: parent
            anchors.margins: 6
            spacing: 4

            // LEFT
            RowLayout {
                id: leftSection
                spacing: 4
                Layout.alignment: Qt.AlignVCenter

                Clock {
                    height: 22
                }
                Window {
                    height: 22
                }
            }

            Item { Layout.fillWidth: true }

            // RIGHT
            RowLayout {
                id: rightSection
                spacing: 4
                Layout.alignment: Qt.AlignVCenter

                Network {
                    height: 22
                }
                Volume {
                    height: 22
                }
                Tray {
                    window: root
                    height: 22
                }
                Notification {
                    height: 22
                }
            }
        }

        // ───── Center Overlay ─────
        Item {
            anchors.centerIn: parent
            height: parent.height
            width: mediaCapsule.implicitWidth

            Media {
                id: mediaCapsule
                height: 22
                anchors.centerIn: parent
            }
        }
    }
}