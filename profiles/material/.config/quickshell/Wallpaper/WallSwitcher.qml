pragma Singleton
pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel 2.10
import qs.Common
import qs.Bar
import qs.Config 

Singleton {
    id: root

    // Link this to your persistent Config singleton
    property string currentWall: Config.currentWallpaper
    property string wallDir: "file://" + Quickshell.env("HOME") + "/ivyos/themes/wallpapers/"
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
            color: Theme.color.base
            border.width: 2
            border.color: Theme.color.accentDim
            radius: 12
            focus: true  
        
            Keys.onPressed: (event) => {  
                if (event.key === Qt.Key_Escape) {  
                    root.switcherVisible = false;  
                }  
            }  
  
            onVisibleChanged: if (visible) forceActiveFocus()  
        
            MouseArea { anchors.fill: parent; onClicked: {} }  

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 5

                Rectangle {
                    Layout.fillWidth: true
                    Layout.margins: 2
                    Layout.bottomMargin: 0
                    topLeftRadius: 10
                    topRightRadius: 10
                    bottomLeftRadius: 10
                    bottomRightRadius: 10
                    implicitHeight: 30
                    color: Theme.color.surface

                    RowLayout {
                        id: themeDirectoryDisplay
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            text: "Select Wallpaper"
                            color: Theme.color.text
                            font.pixelSize: Theme.font.sm
                            font.family: Theme.font.ui
                            font.weight: Theme.font.medium
                        }
                        Text {
                            text: " • "
                            color: Theme.color.accentDim
                            font.pixelSize: Theme.font.sm
                            font.family: Theme.font.ui
                            font.weight: Theme.font.normal
                        }
                        Text {
                            text: root.wallDir
                            color: Theme.color.subtext
                            font.pixelSize: Theme.font.sm
                            font.family: Theme.font.ui
                            font.weight: Theme.font.normal
                        }
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
                    color: Theme.color.base

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
                            

                            border.color: Config.currentWallpaper === filePath ? Theme.color.subtext : "transparent"
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
                                onClicked: {
                                    Config.setWallpaper(imageRounder.filePath);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}