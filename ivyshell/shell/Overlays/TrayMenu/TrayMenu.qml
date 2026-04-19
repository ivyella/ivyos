pragma Singleton  
pragma ComponentBehavior: Bound  
import QtQuick  
import QtQuick.Layouts  
import Quickshell  
import Quickshell.Wayland  
import Quickshell.Services.SystemTray  
import qs.Reusables.Theme
import qs.Reusables.MdIcons

Singleton {  
    id: root  
  
    property bool visible: false  
    property var menu: null  
    property real anchorX: 0  
    property real anchorY: 0  
  
    function open(menuHandle, gx, gy) {  
        root.menu = menuHandle  
        root.anchorX = gx  
        root.anchorY = gy  
        root.visible = true  
    }  
  
    function close() {  
        root.visible = false  
        root.menu = null  
    }  
  
    // ── Menu window ───────────────────────────────────────────────────────────  
    PanelWindow {  
        id: menuWindow  
        visible: root.visible && root.menu !== null  
        WlrLayershell.layer: WlrLayer.Overlay  
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand  
        anchors { top: true; bottom: true; left: true; right: true }  
        color: "transparent"  
        exclusionMode: ExclusionMode.Ignore  
  
        // dismiss on click outside (accept both left and right clicks)  
        MouseArea {  
            anchors.fill: parent  
            acceptedButtons: Qt.LeftButton | Qt.RightButton  
            onClicked: root.close()  
        }  
        
        QsMenuOpener {  
            id: opener  
            menu: root.menu  
        }  
  
        Rectangle {  
            id: menuPanel  
            width: 200  
            implicitHeight: menuCol.implicitHeight + Theme.spacing.sm * 2  
            radius: Theme.radius.md  
            color: Theme.color.bg2  
            border.width: 1  
            border.color: Theme.color.border0  
            z: 10  
  
            x: Math.max(Theme.spacing.sm,  
               Math.min(root.anchorX - width / 2,  
                        menuWindow.width - width - Theme.spacing.sm))  
            y: root.anchorY  
  
            // eat clicks so they don't fall through to the dismiss MouseArea  
            MouseArea { anchors.fill: parent; onClicked: {} }  
  
            Column {  
                id: menuCol  
                anchors {  
                    left: parent.left  
                    right: parent.right  
                    top: parent.top  
                    margins: Theme.spacing.sm  
                }  
                spacing: 2  
  
                Repeater {  
                    model: opener.children  
  
                    delegate: Loader {  
                        required property var modelData  
                        width: menuCol.width  
  
                        sourceComponent: modelData.isSeparator ? separatorComp : itemComp  
                        property var itemData: modelData  
                    }  
                }  
            }  
        }  
  
        // ── Separator ─────────────────────────────────────────────────────────  
        Component {  
            id: separatorComp  
            Rectangle {  
                width: parent ? parent.width : 0  
                height: 9  
                color: "transparent"  
  
                Rectangle {  
                    anchors.centerIn: parent  
                    width: parent.width  
                    height: 1  
                    color: Theme.color.border0  
                }  
            }  
        }  
  
        // ── Menu item ─────────────────────────────────────────────────────────  
        Component {  
            id: itemComp  
  
            Rectangle {  
                id: menuItem  
                width: parent ? parent.width : 0  
                height: 32  
                radius: Theme.radius.sm  
                color: itemMouse.containsMouse ? Theme.color.bg3 : "transparent"  
  
                property var itemData: parent ? (parent as Loader).itemData : null  
                readonly property bool hasSubmenu: itemData?.children?.length > 0  
  
                RowLayout {  
                    anchors.fill: parent  
                    anchors.leftMargin: Theme.padding.sm  
                    anchors.rightMargin: Theme.padding.sm  
                    spacing: Theme.spacing.sm  
  
                    Text {  
                        visible: itemData?.checkState !== undefined && itemData?.checkState !== null  
                        text: itemData?.checkState === 2 ? "󰄵" : itemData?.checkState === 1 ? "󰍕" : ""  
                        color: Theme.color.accent0  
                        font.pixelSize: Theme.font.sm  
                        font.family: Theme.font.mono  
                        width: 14  
                    }  
  
                    Text {  
                        Layout.fillWidth: true  
                        text: itemData?.text ?? ""  
                        color: itemData?.enabled === false  
                            ? Theme.color.fg2  
                            : Theme.color.fg0  
                        font.pixelSize: Theme.font.sm  
                        font.family: Theme.font.ui  
                        elide: Text.ElideRight  
                    }  
  
                    Text {  
                        visible: menuItem.hasSubmenu  
                        text: ""  
                        color: Theme.color.fg2  
                        font.pixelSize: Theme.font.sm  
                        font.family: Theme.font.mono  
                    }  
                }  
  
                MouseArea {  
                    id: itemMouse  
                    anchors.fill: parent  
                    hoverEnabled: true  
                    cursorShape: Qt.PointingHandCursor  
                    enabled: menuItem.itemData?.enabled !== false  
                    onClicked: {  
                        if (!menuItem.hasSubmenu) {  
                            menuItem.itemData?.triggered()  
                            root.close()  
                        }  
                    }  
                }  
            }  
        }  
    }  
}