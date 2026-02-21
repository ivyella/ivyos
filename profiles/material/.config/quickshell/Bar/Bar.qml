pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.Bar
import qs.Bar.Modules
import qs.Common

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

        implicitHeight: Theme.height.bar
        color: Theme.color.base

        // ───── Base layout: LEFT + RIGHT only ─────
        RowLayout {
            id: edgeLayout
            anchors.fill: parent
            anchors.leftMargin: Theme.margin.sm
            anchors.rightMargin: Theme.margin.sm
            anchors.topMargin: Theme.margin.xs
            anchors.bottomMargin: Theme.margin.xs
            

            // LEFT
            RowLayout {
                id: leftSection
                spacing: Theme.spacing.sm
                Layout.alignment: Qt.AlignVCenter

                Clock {}
                Window {}
            }

            Item { Layout.fillWidth: true }

            // RIGHT
            RowLayout {
                id: rightSection
                spacing: Theme.spacing.sm
                Layout.alignment: Qt.AlignVCenter

                Network {}
                Volume {}
                Tray {
                    window: root
                }
                Notification {}
            }
        }

        // ───── Center Overlay ─────
        Item {
            anchors.centerIn: parent
            height: parent.height
            width: mediaCapsule.implicitWidth

            Media {
                id: mediaCapsule
                anchors.centerIn: parent
            }
        }
    }
}