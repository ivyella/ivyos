// Settings/Pages/WallpaperPage.qml
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel 2.10
import Quickshell
import qs.Overlays
import qs.Reusables
import qs.Surfaces
import qs.Services

Item {
    id: root

    property string wallDir: "file://" + Quickshell.env("HOME") + "/ivyos/ivyshell/themes/wallpapers/"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.spacing.lg
        spacing: Theme.spacing.md

        // Header
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: headerCol.implicitHeight + Theme.spacing.lg * 2
            color: Theme.color.bg0
            radius: Theme.radius.md

            ColumnLayout {
                id: headerCol
                anchors.centerIn: parent
                spacing: Theme.spacing.xs

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Wallpaper"
                    color: Theme.color.fg0
                    font.pixelSize: Theme.font.lg
                    font.family: Theme.font.ui
                    font.weight: Font.Bold
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Choose a wallpaper"
                    color: Theme.color.fg2
                    font.pixelSize: Theme.font.sm
                    font.family: Theme.font.ui
                }
            }
        }

        // Grid
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.color.bg0
            radius: Theme.radius.md
            clip: true

            GridView {
                id: grid
                anchors.fill: parent
                anchors.margins: Theme.spacing.md
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                cellWidth: 150
                cellHeight: 100
                leftMargin: (width % cellWidth) / 2

                model: FolderListModel {
                    folder: root.wallDir
                    nameFilters: ["*.png", "*.jpg", "*.jpeg"]
                }

                delegate: Item {
                    id: wallDelegate
                    required property string filePath
                    width: grid.cellWidth
                    height: grid.cellHeight

                    Rectangle {
                        anchors.centerIn: parent
                        width: 135
                        height: 85
                        radius: Theme.radius.md
                        clip: true
                        color: Theme.color.bg1

                        Image {
                            anchors.fill: parent
                            asynchronous: true
                            source: wallDelegate.filePath
                            fillMode: Image.PreserveAspectCrop
                            sourceSize.width: 135
                            sourceSize.height: 85
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: "transparent" 
                            radius: parent.radius
                            border.width: 2
                            border.color: Config.currentWallpaper === wallDelegate.filePath
                                ? Theme.color.accent0
                                : "transparent"

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Config.setWallpaper(wallDelegate.filePath)
                            }
                        }
                    }
                }
            }
        }
    }
}