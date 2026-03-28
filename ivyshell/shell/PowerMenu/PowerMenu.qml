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
            onClicked: root.menuVisible = false  
        }  
  
        Rectangle {  
            anchors.centerIn: parent  
            width: buttonRow.implicitWidth + Theme.spacing.xl * 2
            height: buttonRow.implicitHeight + Theme.spacing.xl * 2
            color: Theme.color.bg0
            border.width: 2  
            border.color: Theme.color.border0
            radius: Theme.radius.lg

            focus: true  
            Keys.onPressed: (event) => {  
                if (event.key === Qt.Key_Escape)  
                    root.menuVisible = false  
            }  
            onVisibleChanged: if (visible) forceActiveFocus()  
            MouseArea { anchors.fill: parent; onClicked: {} }

            RowLayout {  
                id: buttonRow  
                anchors.centerIn: parent  
                spacing: Theme.spacing.lg

                Repeater {
                    model: [
                        { icon: "logout",             label: "Logout",   cmd: "loginctl terminate-user " + Quickshell.env("USER") },
                        { icon: "restart_alt",        label: "Reboot",   cmd: "reboot" },
                        { icon: "power_settings_new", label: "Shutdown", cmd: "shutdown now" }
                    ]

                    delegate: Rectangle {
                        id: btn
                        required property var modelData
                        property bool hovered: false

                        Layout.preferredWidth: 110
                        Layout.preferredHeight: 110
                        radius: Theme.radius.md
                        color: hovered ? Theme.color.accent0 : Theme.color.bg2

                        Behavior on color { ColorAnimation { duration: 150 } }

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: Theme.spacing.sm

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: btn.modelData.icon
                                color: btn.hovered ? Theme.color.bg0 : Theme.color.fg0
                                font.family: "Material Symbols Rounded"
                                font.weight: 800
                                font.pixelSize: 42
                                font.variableAxes: ({ "FILL": "1", "opsz": Theme.icon.lg })
                                renderType: Text.NativeRendering

                                Behavior on color { ColorAnimation { duration: 150 } }
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: btn.modelData.label
                                color: btn.hovered ? Theme.color.bg0 : Theme.color.fg1
                                font.pixelSize: Theme.font.sm
                                font.family: Theme.font.ui
                                font.weight: Theme.font.medium

                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: btn.hovered = true
                            onExited: btn.hovered = false
                            onClicked: {
                                Quickshell.execDetached(["sh", "-c", btn.modelData.cmd])
                                root.menuVisible = false
                            }
                        }
                    }
                }
            }
        }
    }
}