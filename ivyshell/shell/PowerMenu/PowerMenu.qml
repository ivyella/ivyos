pragma Singleton  
pragma ComponentBehavior: Bound  
import Quickshell  
import Quickshell.Wayland  
import Quickshell.Io  
import QtQuick  
import QtQuick.Layouts  
import qs.Common  
  
Singleton {  
    id: root  
    property bool menuVisible: false  
  
    IpcHandler {  
        target: "powerMenu"  
        function toggle() {  
            root.menuVisible = !root.menuVisible  
        }  
    }  
  
    PanelWindow {  
        visible: root.menuVisible  
        WlrLayershell.layer: WlrLayer.Overlay  
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand  
        anchors { top: true; bottom: true; left: true; right: true }  
        color: "transparent"  
        exclusionMode: ExclusionMode.Ignore  
  
        MouseArea {  
            anchors.fill: parent  
            propagateComposedEvents: false  
            onClicked: root.menuVisible = false  
        }  
        
        
        Rectangle {  
            anchors.centerIn: parent  
            width: buttonRow.implicitWidth + 10  
            height: buttonRow.implicitHeight + 40  
            color: Theme.color.bg0
            border.width: 2  
            border.color: Theme.color.border0
            radius: 20  

            focus: true  
        
            Keys.onPressed: (event) => {  
                if (event.key === Qt.Key_Escape) {  
                    root.menuVisible = false;  
                }  
            }  
        
            onVisibleChanged: if (visible) forceActiveFocus()  
        
            MouseArea { anchors.fill: parent; onClicked: {} } 
            RowLayout {  
                id: buttonRow  
                anchors.centerIn: parent  
                spacing: 20  
  
                Item { Layout.fillWidth: true }  
  
                Rectangle {  
                    Layout.preferredWidth: 140  
                    Layout.preferredHeight: 140  
                    radius: 16  
                    color: Theme.color.bg2
  
                    MouseArea {  
                        id: mouseArea1  
                        anchors.fill: parent  
                        hoverEnabled: true  
                        cursorShape: Qt.PointingHandCursor  
                        onEntered: parent.color = Theme.color.accent0  
                        onExited: parent.color = Theme.color.bg2  
                        onClicked: {  
                            Quickshell.execDetached(["sh", "-c", "loginctl terminate-user " + Quickshell.env("USER")])  
                            root.menuVisible = false  
                        }  
                    }  
  
                    Text {  
                        anchors.centerIn: parent  
                        text: "Logout"  
                        color: Theme.color.fg0
                        font.pixelSize: 16  
                        font.family: Theme.font.ui  
                        font.weight: Theme.font.medium  
                    }  
                }  
  
                Rectangle {  
                    Layout.preferredWidth: 140  
                    Layout.preferredHeight: 140  
                    radius: 16  
                    color: Theme.color.bg2
  
                    MouseArea {  
                        id: mouseArea2  
                        anchors.fill: parent  
                        hoverEnabled: true  
                        cursorShape: Qt.PointingHandCursor  
                        onEntered: parent.color = Theme.color.accent0  
                        onExited: parent.color = Theme.color.bg2
                        onClicked: {  
                            Quickshell.execDetached(["sh", "-c", "reboot"])  
                            root.menuVisible = false  
                        }  
                    }  
  
                    Text {  
                        anchors.centerIn: parent  
                        text: "Reboot"  
                        color: Theme.color.fg0
                        font.pixelSize: 16  
                        font.family: Theme.font.ui  
                        font.weight: Theme.font.medium  
                    }  
                }  
  
                Rectangle {  
                    Layout.preferredWidth: 140  
                    Layout.preferredHeight: 140  
                    radius: 16  
                    color: Theme.color.bg2
  
                    MouseArea {  
                        id: mouseArea3  
                        anchors.fill: parent  
                        hoverEnabled: true  
                        cursorShape: Qt.PointingHandCursor  
                        onEntered: parent.color = Theme.color.accent0
                        onExited: parent.color = Theme.color.bg2 
                        onClicked: {  
                            Quickshell.execDetached(["sh", "-c", "shutdown now"])  
                            root.menuVisible = false  
                        }  
                    }  
  
                    Text {  
                        anchors.centerIn: parent  
                        text: "Shutdown"  
                        color: Theme.color.fg0
                        font.pixelSize: 16  
                        font.family: Theme.font.ui  
                        font.weight: Theme.font.medium  
                    }  
                }  
  
                Item { Layout.fillWidth: true }  
            }  
        }  
    }  
}