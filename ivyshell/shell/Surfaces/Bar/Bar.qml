pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.Reusables.Theme
import qs.Services.Notification
import qs.Surfaces.Bar.Modules
import qs.Reusables.Displays

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        id: root
        required property var modelData
        screen: modelData
        readonly property bool isMain: modelData.name === Displays.primary
        readonly property bool isSecondary: modelData.name === Displays.secondary

        anchors {
            top: true
            left: true
            right: true
        }

        implicitHeight: Theme.height.bar
        color: Theme.color.bg0

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

                SettingsButton {}
                Clock {}
                Window {visible: root.isMain}
            }

            Item { Layout.fillWidth: true }

            // RIGHT
            RowLayout {
                id: rightSection
                spacing: Theme.spacing.sm
                Layout.alignment: Qt.AlignVCenter

                Network {visible: root.isMain}
                Volume {visible: root.isMain}
                Battery {
                    id: batteryWidget
                    visible: root.isMain && batteryWidget.batteryAvailable
                }
                Rectangle {
                    color: Theme.color.bg2
                    radius: Theme.radius.lg
                    height: Theme.height.sm
                    implicitWidth: groupRow.implicitWidth + Theme.padding.md * 0

                    RowLayout {
                        id: groupRow
                        anchors.centerIn: parent
                        spacing: 0

                        Tray { 
                            //window: root
                            visible: root.isMain
                            }
                        Notification {visible: root.isMain}
                        
                    }
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
                anchors.centerIn: parent
            }
            
        }
    }
}