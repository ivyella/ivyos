pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt.labs.folderlistmodel 2.10
import Quickshell
import Quickshell.Io
import qs.Overlays
import qs.Reusables
import qs.Surfaces
import qs.Services

Item {
    id: root

    property string themeDir: "file://" + Quickshell.env("HOME") + "/ivyos/ivyshell/themes/colors/"

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
                    text: "Theme"
                    color: Theme.color.fg0
                    font.pixelSize: Theme.font.lg
                    font.family: Theme.font.ui
                    font.weight: Font.Bold
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Choose a color scheme"
                    color: Theme.color.fg2
                    font.pixelSize: Theme.font.sm
                    font.family: Theme.font.ui
                }
            }
        }

        // Content
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Theme.color.bg0
            radius: Theme.radius.md
            clip: true

            ScrollView {
                id: scrollView
                anchors.fill: parent
                anchors.margins: Theme.spacing.md
                clip: true
                contentWidth: availableWidth

                ColumnLayout {
                    width: scrollView.availableWidth
                    spacing: Theme.spacing.lg

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

    component PackRow: ColumnLayout {
        id: packRow
        property string packPath
        property string packBaseName
        property var packData: ({})
        property var variantKeys: []

        spacing: Theme.spacing.sm

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
            Layout.leftMargin: Theme.spacing.xs
            text: packRow.packData.pack ?? packRow.packBaseName
            color: Theme.color.fg2
            font.pixelSize: Theme.font.sm
            font.family: Theme.font.ui
            font.weight: Theme.font.medium
        }

        Flow {
            Layout.fillWidth: true
            spacing: Theme.spacing.sm

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
                    radius: Theme.radius.md
                    color: Theme.color.bg2
                    border.width: 2
                    border.color: isActive ? Theme.color.accent0 : Theme.color.border0

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: Theme.spacing.sm

                        Row {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: Theme.spacing.xs

                            Repeater {
                                model: ["accent0", "fg0", "fg1", "bg0", "bg2"]
                                delegate: Rectangle {
                                    required property string modelData
                                    width: 16; height: 16; radius: Theme.radius.xs
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
                        onClicked: Config.setTheme(packRow.packPath, variantCard.modelData)
                    }
                }
            }
        }
    }
}