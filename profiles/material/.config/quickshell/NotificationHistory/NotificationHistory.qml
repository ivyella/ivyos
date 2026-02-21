pragma Singleton
pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.Common
import QtQuick.Controls
import qs.Notification

Singleton {
    id: root
    property bool historyVisible: false

    IpcHandler {
        target: "NotificationHistory"
        function toggle(): void {
            root.historyVisible = !root.historyVisible;
        }
    }

    PanelWindow {
        visible: root.historyVisible
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        MouseArea {
            anchors.fill: parent
            onClicked: root.historyVisible = false
        }

        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 40
            anchors.rightMargin: 10
            width: 400
            height: Math.min(contentCol.implicitHeight + 32, 600)
            color: Theme.color.base
            radius: 16
            border.width: 2
            border.color: Theme.color.accentDeep

              
            focus: true  
            Keys.onPressed: (event) => {  
                if (event.key === Qt.Key_Escape) {  
                    root.historyVisible = false;  
                }  
            }  
        
            onVisibleChanged: if (visible) forceActiveFocus()  
        


            MouseArea { anchors.fill: parent; onClicked: {} }

            ColumnLayout {
                id: contentCol
                anchors.fill: parent
                anchors.margins: 16
                spacing: 8

                // ── Header ──
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Notifications"
                        font.pixelSize: 16
                        font.family: Theme.font.ui
                        font.weight: Theme.font.medium
                        color: Theme.color.text
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        width: 70
                        height: 28
                        radius: 14
                        color: clearArea.containsMouse ? Theme.color.accent : Theme.color.surface

                        Text {
                            anchors.centerIn: parent
                            text: "Clear"
                            font.pixelSize: 12
                            font.family: Theme.font.ui
                            color: Theme.color.text
                        }

                        MouseArea {
                            id: clearArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: NotiServer.history = []
                        }
                    }
                }

                // ── Divider ──
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Theme.color.accentDeep
                }

                // ── List ──
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    ListView {
                        id: historyList
                        width: parent.width
                        spacing: 8
                        model: NotiServer.history

                        delegate: Rectangle {
                            required property var modelData
                            width: historyList.width
                            implicitHeight: itemCol.implicitHeight + 20
                            color: Theme.color.surfaceLow
                            radius: 12
                            border.width: 1
                            border.color: Theme.color.accentDeep

                            ColumnLayout {
                                id: itemCol
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 4

                                RowLayout {
                                    Layout.fillWidth: true

                                    Text {
                                        text: modelData.appName ?? ""
                                        font.pixelSize: Theme.font.xs
                                        font.family: Theme.font.ui
                                        color: Theme.color.subtext
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: modelData.timestamp ? Qt.formatDateTime(new Date(Date.parse(modelData.timestamp)), "hh:mm AP") : ""
                                        font.pixelSize: 11
                                        font.family: Theme.font.ui
                                        color: Theme.color.subtext
                                    }
                                }

                                Text {
                                    text: modelData.summary ?? ""
                                    font.bold: true
                                    font.pixelSize: 13
                                    font.family: Theme.font.ui
                                    color: Theme.color.text
                                    Layout.fillWidth: true
                                    wrapMode: Text.WordWrap
                                }

                                Text {
                                    text: modelData.body ?? ""
                                    font.pixelSize: 12
                                    font.family: Theme.font.ui
                                    color: Theme.color.subtext
                                    Layout.fillWidth: true
                                    wrapMode: Text.WordWrap
                                    visible: modelData.body !== ""
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: historyList.count === 0
                            text: "No notifications"
                            font.pixelSize: Theme.font.md
                            font.family: Theme.font.ui
                            color: Theme.color.subtext
                        }
                    }
                }
            }
        }
    }
}