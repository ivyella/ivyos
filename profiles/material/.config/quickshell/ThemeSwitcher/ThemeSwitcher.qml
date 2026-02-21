pragma Singleton
pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel 2.10
import qs.Common
import qs.Config

Singleton {
    id: root
    property bool switcherVisible: false
    
    property string themeDir: "file://" + Quickshell.env("HOME") + "/ivyos/profiles/material/.config/quickshell/Common/Themes/"

    IpcHandler {
        target: "theme"
        function toggle(): void {
            root.switcherVisible = !root.switcherVisible
        }
    }

    PanelWindow {
        visible: root.switcherVisible
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        
        // FIX: PanelWindow uses specific edge anchors, not anchors.fill
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
                    radius: 10
                    implicitHeight: 30
                    color: Theme.color.surface

                    Text {
                        anchors.centerIn: parent
                        text: "Select Theme"
                        color: Theme.color.text
                        font.pixelSize: Theme.font.sm
                        font.family: Theme.font.ui
                        font.weight: Theme.font.medium
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 10
                    Layout.topMargin: 0
                    radius: 12
                    color: Theme.color.base

                    GridView {
                        id: gridRoot
                        anchors.fill: parent
                        anchors.margins: 20
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        cellWidth: 200
                        cellHeight: 120
                        leftMargin: (width % cellWidth) / 2

                        model: FolderListModel {
                            folder: root.themeDir
                            nameFilters: ["*.json"]
                            showDirs: false
                            showFiles: true
                        }

                        delegate: Rectangle {
                            id: themeCard
                            required property string fileBaseName 
                            required property string filePath

                            width: 180
                            height: 100
                            radius: 12
                            color: Theme.color.surface
                            border.width: 2
                            border.color: Config.currentTheme === themeCard.fileBaseName ? Theme.color.accent : Theme.color.outline

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 8

                                Rectangle {
                                    Layout.alignment: Qt.AlignHCenter
                                    width: 120
                                    height: 40
                                    radius: 8
                                    color: Theme.color.surfaceMid

                                    Row {
                                        anchors.centerIn: parent
                                        spacing: 4
                                        Rectangle { width: 20; height: 20; radius: 4; color: Theme.color.accent }
                                        Rectangle { width: 20; height: 20; radius: 4; color: Theme.color.text }
                                        Rectangle { width: 20; height: 20; radius: 4; color: Theme.color.subtext }
                                    }
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: themeCard.fileBaseName
                                    color: Theme.color.text
                                    font.pixelSize: Theme.font.md
                                    font.family: Theme.font.ui
                                    font.weight: Theme.font.medium
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Config.setTheme(themeCard.filePath)
                            }
                        }
                    }
                }
            }
        }
    }
}