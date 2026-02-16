pragma Singleton
pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel 2.10
import qs.Common

Singleton {
    id: root

    property string currentWall: "file:///home/ivy/ivyos/themes/wallpapers/a_group_of_trees_with_green_leaves.jpg"
    property string wallDir: "file:///home/ivy/ivyos/themes/wallpapers/"
    property bool switcherVisible: false

    IpcHandler {
        target: "wallpaper"
        function toggle(): void {
            root.switcherVisible = !root.switcherVisible;
        }
    }

    PanelWindow {
        visible: root.switcherVisible
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        MouseArea {
            anchors.fill: parent
            onClicked: root.switcherVisible = false
        }

        Rectangle {
            anchors.centerIn: parent
            width: 900
            height: 600
            color: Colors.surface
            radius: 16

            MouseArea { anchors.fill: parent; onClicked: {} }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 5

                Rectangle {
                    Layout.fillWidth: true
                    Layout.margins: 10
                    Layout.bottomMargin: 0
                    topLeftRadius: 12
                    topRightRadius: 12
                    bottomLeftRadius: 4
                    bottomRightRadius: 4
                    implicitHeight: 30
                    color: Colors.surfaceContainerLow

                    Text {
                        anchors.centerIn: parent
                        text: "Wallpapers in " + root.wallDir
                        color: Colors.textOnSurface
                        font.pixelSize: Metrics.fontSize
                        font.family: Metrics.fontFamily
                        font.bold: true
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 10
                    Layout.topMargin: 0
                    topLeftRadius: 4
                    topRightRadius: 4
                    bottomLeftRadius: 12
                    bottomRightRadius: 12
                    color: Colors.surfaceContainerLow

                    GridView {
                        id: gridRoot
                        anchors.fill: parent
                        anchors.margins: 20
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        snapMode: GridView.SnapToRow
                        cellWidth: 130
                        cellHeight: 90
                        leftMargin: (width % cellWidth) / 2

                        model: FolderListModel {
                            folder: root.wallDir
                            nameFilters: ["*.png", "*.jpg", "*.jpeg"]
                        }

                        delegate: Rectangle {
                            id: imageRounder
                            implicitHeight: 80
                            implicitWidth: 120
                            radius: 12
                            clip: true
                            color: "transparent"
                            required property string filePath
                            border.color: root.currentWall === filePath ? Colors.primary : "transparent"
                            border.width: 2

                            Image {
                                anchors.fill: parent
                                asynchronous: true
                                source: imageRounder.filePath
                                fillMode: Image.PreserveAspectCrop
                                sourceSize.width: 120
                                sourceSize.height: 80
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.currentWall = imageRounder.filePath
                            }
                        }
                    }
                }
            }
        }
    }
}