pragma Singleton
pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.folderlistmodel 2.10
import qs.Common
import qs.Config

Singleton {
    id: root
    property bool switcherVisible: false

    property string themeDir: "file://" + Quickshell.env("HOME") + "/ivyos/ivyshell/themes/colors/quickshell/"

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
            color: Theme.color.bg0
            border.width: 2
            border.color: Theme.color.accent0
            radius: 12
            focus: true

            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Escape)
                    root.switcherVisible = false
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
                    color: Theme.color.bg2

                    Text {
                        anchors.centerIn: parent
                        text: "Select Theme"
                        color: Theme.color.fg0
                        font.pixelSize: Theme.font.sm
                        font.family: Theme.font.ui
                        font.weight: Theme.font.medium
                    }
                }

                ScrollView {
                    id: scrollView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 10
                    Layout.topMargin: 0
                    clip: true
                    contentWidth: availableWidth

                    ColumnLayout {
                        width: scrollView.availableWidth
                        spacing: 12

                        Repeater {
                            model: FolderListModel {
                                folder: root.themeDir
                                nameFilters: ["*.json"]
                                showDirs: false
                                showFiles: true
                            }

                            delegate: PackRow {
                                required property string fileBaseName
                                required property string filePath
                                Layout.fillWidth: true
                                packPath: filePath
                                packBaseName: fileBaseName
                            }
                        }
                    }
                }
            }
        }
    }

    component PackRow: ColumnLayout {
        id: packRow
        property string packPath
        property string packBaseName
        property var packData: ({})
        property var variantKeys: []

        spacing: 6

        FileView {
            id: packFile
            path: packRow.packPath.startsWith("file://") ? packRow.packPath.slice(7) : packRow.packPath
            blockLoading: true
            watchChanges: true
            onFileChanged: reload()
            onLoaded: {
                try {
                    const parsed = JSON.parse(packFile.text())
                    packRow.packData = parsed
                    packRow.variantKeys = parsed.variants ? Object.keys(parsed.variants) : []
                } catch (e) {
                    console.warn("Failed to parse pack:", packRow.packPath, e)
                }
            }
            Component.onCompleted: reload()
        }

        Text {
            Layout.leftMargin: 4
            text: packRow.packData.pack ?? packRow.packBaseName
            color: Theme.color.fg1
            font.pixelSize: Theme.font.sm
            font.family: Theme.font.ui
            font.weight: Theme.font.medium
        }

        Flow {
            Layout.fillWidth: true
            spacing: 8

            Repeater {
                model: packRow.variantKeys

                delegate: Rectangle {
                    id: variantCard
                    required property string modelData

                    readonly property var variantObj: packRow.packData.variants?.[modelData] ?? {}
                    readonly property bool isActive:
                        Config.currentTheme === packRow.packPath &&
                        Config.currentVariant === modelData

                    width: 160
                    height: 90
                    radius: 10
                    color: Theme.color.bg2
                    border.width: 2
                    border.color: isActive ? Theme.color.accent0 : Theme.color.border0

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        Row {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 4

                            Repeater {
                                model: ["accent0", "fg0", "fg1", "bg0", "bg2"]
                                delegate: Rectangle {
                                    required property string modelData
                                    width: 16; height: 16; radius: 3
                                    color: variantCard.variantObj.color?.[modelData] ?? Theme.color.bg3
                                }
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: variantCard.variantObj.name ?? variantCard.modelData
                            color: Theme.color.fg0
                            font.pixelSize: Theme.font.sm
                            font.family: Theme.font.ui
                            font.weight: Theme.font.medium
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Config.setTheme(packRow.packPath, variantCard.modelData)
                            root.switcherVisible = false
                        }
                    }
                }
            }
        }
    }
}
