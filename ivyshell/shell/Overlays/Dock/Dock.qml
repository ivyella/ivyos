pragma ComponentBehavior: Bound  
  
import QtQuick  
import Quickshell  
import Quickshell.Io  
import Quickshell.Wayland  
import Quickshell.Widgets  
import qs.Reusables.Theme  
import qs.Services  
  
Variants {  
    id: dockVariants  
    model: Quickshell.screens  
  
    delegate: PanelWindow {  
  
        id: dock  
        required property var modelData  
        screen: modelData  
  
        WlrLayershell.namespace: "ivyshell-dock"  
        WlrLayershell.layer: WlrLayer.Overlay  
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None  
        exclusionMode: dock.revealed ? ExclusionMode.Normal : ExclusionMode.Ignore  
  
        anchors.bottom: true  
        anchors.left: true  
        anchors.right: true  
  
        implicitWidth: screen.width  
        implicitHeight: dockHeight + dockBottomMargin + animHeadroom  
        color: "transparent"  
  
        readonly property int dockHeight: 48  
        readonly property int dockBottomMargin: 0  
        readonly property int animHeadroom: Math.ceil(dockHeight * 0.35)  
        readonly property int pillWidth: Math.max(WindowService.dockModel.length * 58 + 40, 120)  
  
        property bool revealed: false  
        property bool revealSticky: false  
        property bool isHoveringDock: false  
        property int hoveredItemCount: 0  
  
        property real slideOffset: revealed ? 0 : (dockHeight + dockBottomMargin + 10)  
        Behavior on slideOffset {  
            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }  
        }  
  
        // ── picker state ──────────────────────────────  
        property var openPicker: null  
  
        function closeOpenPicker() {  
            if (dock.openPicker) {  
                dock.openPicker.visible = false  
                dock.openPicker = null  
            }  
        }  
  
        // ── cycling ───────────────────────────────────  
        property var cycleIndex: ({})  
  
        function cycleWindows(appId, windows) {  
            if (!windows || windows.length === 0) return  
  
            const idx = dock.cycleIndex[appId] ?? 0  
            const next = idx % windows.length  
            const win = windows[next]  
  
            if (win && win.windowId >= 0) {  
                Quickshell.execDetached([  
                    "niri", "msg", "action", "focus-window",  
                    "--id", String(win.windowId)  
                ])  
            }  
  
            const updated = Object.assign({}, dock.cycleIndex)  
            updated[appId] = (next + 1) % windows.length  
            dock.cycleIndex = updated  
        }  
  
        // ── hide timer ───────────────────────────────  
        Timer {  
            id: hideTimer  
            interval: 500  
            onTriggered: {  
                if (dock.hoveredItemCount === 0 && !dock.openPicker) {  
                    dock.revealed = false  
                    dock.revealSticky = false  
                }  
            }  
        }  
  
        // ── hover state monitor (NEW) ──────────────────  
        // This monitors all hover states without modifying MouseArea logic  
        Timer {  
            id: hoverMonitorTimer  
            interval: 100  
            running: dock.revealed  
              
            onTriggered: {  
                // Check if we should start hide timer but haven't  
                const shouldHide = !dockMouseArea.containsMouse &&   
                                 dock.hoveredItemCount === 0 &&   
                                 !dock.openPicker &&  
                                 dock.revealed  
                  
                if (shouldHide && !hideTimer.running) {  
                    hideTimer.restart()  
                }  
            }  
        }  
  
        // ── mask ─────────────────────────────────────  
        Item {  
            id: maskItem  
            visible: false  
  
            x: dock.revealed ? 0 : (parent.width / 2 - dock.pillWidth / 2)  
            y: dock.revealed ? 0 : (parent.height - 1)  
            width: dock.revealed ? parent.width : dock.pillWidth  
            height: dock.revealed ? parent.height : 1  
        }  
  
        mask: Region { item: maskItem }  
  
        // ── hover detection area ──────────────────────  
        MouseArea {  
            id: dockMouseArea  
            hoverEnabled: true  
            acceptedButtons: Qt.NoButton  
  
            height: dock.revealed ? (dock.dockHeight + dock.dockBottomMargin + 20) : 1  
            width: dock.revealed ? (dock.pillWidth + 40) : dock.pillWidth  
  
            anchors.horizontalCenter: parent.horizontalCenter  
            anchors.bottom: parent.bottom  
            anchors.bottomMargin: dock.revealed ? 0 : dock.dockBottomMargin  
  
            Behavior on height {  
                NumberAnimation {  
                    duration: 220  
                    easing.type: Easing.OutCubic  
                }  
            }  
  
            Behavior on width {  
                NumberAnimation {  
                    duration: 220  
                    easing.type: Easing.OutCubic  
                }  
            }  
  
            onContainsMouseChanged: {  
                if (containsMouse) {  
                    dock.revealed = true  
                    dock.revealSticky = true  
                    hideTimer.stop()  
                } else {  
                    if (dock.hoveredItemCount === 0 && !dock.openPicker) {  
                        hideTimer.restart()  
                    }  
                }  
            }  
        }  
  
        // ── dock core ─────────────────────────────────  
        Item {   
            id: dockCore  
            anchors.fill: parent  
  
            Rectangle {  
                id: dockVisual  
  
                width: Math.max(row.implicitWidth + 0, 120)  
                height: dock.dockHeight  
  
                anchors.horizontalCenter: parent.horizontalCenter  
                anchors.bottom: parent.bottom  
                anchors.bottomMargin: dock.dockBottomMargin  
  
                transform: Translate { y: dock.slideOffset }  
  
                    topLeftRadius: Theme.radius.lg    
                    topRightRadius: Theme.radius.lg    
                    bottomLeftRadius: 0  // Sharp bottom-left    
                    bottomRightRadius: 0 // Sharp bottom-right    
                color: Qt.alpha(Theme.color.bg0, 1)    

                Row {  
                    id: row  
                    anchors.centerIn: parent  
                    spacing: 0  
   
                    Repeater {  
                        model: WindowService.dockModel  
  
                        delegate: Item {  
                            id: dockItem  
                            width: 48  
                            height: 48  
                            required property var modelData  
  
                            readonly property string appId:    modelData.appId  
                            readonly property int    winCount: modelData.winCount  
                            readonly property int    focusId:  modelData.focusId  
                            readonly property bool   isFocused: modelData.focused  
                            readonly property var    windows:  modelData.windows  
  
                            property bool hovered: iconMouse.containsMouse  
  
                            // ── picker ───────────────────────  
                            Rectangle {  
                                id: instancePicker  
                                visible: false  
                                width: Math.max(pickerColumn.implicitWidth + 24, 140)  
                                height: pickerColumn.implicitHeight + 16  
                                radius: Theme.radius.md  
                                color: Theme.color.bg1  
                                z: 100  
  
                                parent: dock  
  
                                x: Math.min(    
                                    Math.max(4,    
                                        dockItem.mapToItem(dockVisual, 0, 0).x  // Use dockVisual instead of dock    
                                        + dockItem.width / 2 - width / 2    
                                    ),    
                                    dockVisual.width - width - 4  // Use dockVisual.width instead of dock.width    
                                )    
  
                                y: dockVisual.y + dock.slideOffset - height - 8  
  
                                Column {  
                                    id: pickerColumn  
                                    anchors.centerIn: parent  
                                    spacing: 2  
  
                                    Repeater {  
                                        model: dockItem.windows  
  
                                        delegate: Rectangle {  
                                            required property var modelData  
  
                                            width: Math.max(pickerLabel.implicitWidth + 24, 120)  
                                            height: 28  
                                            radius: Theme.radius.sm  
                                            color: pickHover.containsMouse  
                                                ? Theme.color.bg3  
                                                : "transparent"  
  
                                            Text {  
                                                id: pickerLabel  
                                                anchors.centerIn: parent  
                                                width: parent.width - 24  
                                                text: modelData.title || dockItem.appId  
                                                elide: Text.ElideRight  
                                                color: Theme.color.fg0  
                                                font.pixelSize: 12  
                                            }  
  
                                            MouseArea {  
                                                id: pickHover  
                                                anchors.fill: parent  
                                                hoverEnabled: true  
  
                                                onClicked: {  
                                                    if (modelData.windowId >= 0) {  
                                                        Quickshell.execDetached([  
                                                            "niri", "msg", "action", "focus-window",  
                                                            "--id", String(modelData.windowId)  
                                                        ])  
                                                    }  
                                                    dock.closeOpenPicker()  
                                                }  
  
                                                onContainsMouseChanged: {  
                                                    if (containsMouse) {  
                                                        dock.hoveredItemCount++  
                                                        hideTimer.stop()  
                                                    } else {  
                                                        dock.hoveredItemCount--  
                                                        if (dock.hoveredItemCount === 0 && !dock.openPicker) {  
                                                            hideTimer.restart()  
                                                        }  
                                                    }  
                                                }  
                                            }  
                                        }  
                                    }  
                                }  
                            }  
  
                            // ── icon ─────────────────────────  
                            Rectangle {  
                                anchors.centerIn: parent  
                                width: 40  
                                height: 40  
                                radius: Theme.radius.md  
  
                                color: dockItem.isFocused  
                                    ? Theme.color.bg3  
                                    : dockItem.hovered ? Theme.color.bg2 : "transparent"  
  
                                Image {    
                                    id: iconImg    
                                    anchors.centerIn: parent    
                                    width: 32    
                                    height: 32    
                                    source: WindowService.iconFor(dockItem.appId)    
                                    sourceSize: Qt.size(64, 64)    
                                    fillMode: Image.PreserveAspectFit    
                                    asynchronous: true    
                                    smooth: true    
                                    visible: status === Image.Ready    
                                }    
                                  
                                Text {    
                                    anchors.centerIn: parent    
                                    visible: iconImg.status !== Image.Ready    
                                    text: dockItem.appId ? dockItem.appId.charAt(0).toUpperCase() : "?"    
                                    color: Theme.color.fg0    
                                }  
                            }  
  
                            // ── indicators ───────────────────  
                            Row {  
                                anchors.bottom: parent.bottom  
                                anchors.horizontalCenter: parent.horizontalCenter  
                                spacing: 2  
  
                                Repeater {  
                                    model: Math.min(dockItem.winCount, 3)  
  
                                    Rectangle {  
                                        width: dockItem.winCount === 1 ? 10 : 4  
                                        height: 3  
                                        radius: 2  
  
                                        color: dockItem.isFocused  
                                            ? Theme.color.accent0  
                                            : Theme.color.fg2  
                                    }  
                                }  
                            }  
  
                            // ── input ────────────────────────  
                            MouseArea {  
                                id: iconMouse  
                                anchors.fill: parent  
                                hoverEnabled: true  
                                acceptedButtons: Qt.LeftButton | Qt.RightButton  
  
                                onClicked: mouse => {  
                                    if (mouse.button === Qt.RightButton) {  
                                        if (dockItem.winCount <= 1) {  
                                            dock.cycleWindows(dockItem.appId, dockItem.windows)  
                                            return  
                                        }  
  
                                        if (dock.openPicker === instancePicker) {  
                                            dock.closeOpenPicker()  
                                        } else {  
                                            dock.closeOpenPicker()  
                                            instancePicker.visible = true  
                                            dock.openPicker = instancePicker  
                                        }  
                                    } else {  
                                        dock.closeOpenPicker()  
                                        dock.cycleWindows(dockItem.appId, dockItem.windows)  
                                    }  
                                }  
  
                                onContainsMouseChanged: {  
                                    if (containsMouse) {  
                                        dock.hoveredItemCount++  
                                        dock.revealSticky = true  
                                        hideTimer.stop()  
                                    } else {  
                                        dock.hoveredItemCount--  
                                        if (dock.hoveredItemCount === 0 && !dock.openPicker) {  
                                            hideTimer.restart()  
                                        }  
                                    }  
                                }  
                            }  
                        }  
                    }  
                }  
            }  
        }  
    }  
}