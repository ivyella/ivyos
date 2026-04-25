pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.Reusables.Theme
import qs.Reusables.MdIcons

Item {
    id: root
    property string icon:  ""
    property string label: ""
    property int    value: 0
    property bool showLabel: true
    signal userChanged(int val)

    implicitHeight: sliderCol.implicitHeight
    
    readonly property bool isInteracting: trackMouse.pressed || trackMouse.containsMouse

    Column {
        id:      sliderCol
        width:   parent.width
        spacing: 8

        RowLayout {
            width: parent.width
            visible: showLabel
            spacing: 8

            MdIcons {
                text:     root.icon
                iconSize: 16
                color:    root.isInteracting ? Theme.color.accent0 : Theme.color.fg1
                visible:  root.icon !== ""
                Behavior on color { ColorAnimation { duration: 200 } }
            }

            Text {
                text:             root.label
                Layout.fillWidth: true
                color:            Theme.color.fg1
                font.pixelSize:   12
                font.weight:      Font.Medium
                font.family:      Theme.font.ui
            }

            Text {
                text:           root.value + "%"
                color:          root.isInteracting ? Theme.color.accent0 : Theme.color.fg2
                font.pixelSize: 11
                font.family:    Theme.font.ui
                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }

        Item {
            id: trackContainer
            width:  parent.width
            height: 32 

            Rectangle {
                id: sliderTrack
                anchors.centerIn: parent
                width:  parent.width
                height: 12 
                radius: 4
                color:  Theme.color.bg3
            }

            Rectangle {
                id: activeTrack
                anchors.verticalCenter: parent.verticalCenter
                height: sliderTrack.height
                radius: sliderTrack.radius
                color:  Theme.color.accent0
                
                width: {
                    const travel = sliderTrack.width - thumb.width;
                    const ratio = root.value / 100;
                    return (travel * ratio) + (thumb.width / 2);
                }

                Behavior on width {
                    enabled: !trackMouse.pressed
                    NumberAnimation { duration: 250; easing.type: Easing.OutExpo }
                }
            }


            Rectangle {
                id: thumb
                width: 10
                height: 28
                radius: 5
                color: Theme.color.fg1
                border.width: 3
                border.color: Theme.color.bg1
                
                anchors.verticalCenter: parent.verticalCenter
                
                x: (parent.width - width) * (root.value / 100)

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: Theme.color.fg0
                    opacity: trackMouse.pressed ? 0.16 : (trackMouse.containsMouse ? 0.08 : 0)
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                }

                Behavior on x {
                    enabled: !trackMouse.pressed
                    NumberAnimation { duration: 250; easing.type: Easing.OutExpo }
                }
                
                scale: root.isInteracting ? 1.05 : 1.0
                Behavior on scale { NumberAnimation { duration: 150 } }
            }

            MouseArea {
                id:           trackMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape:  Qt.PointingHandCursor
                preventStealing: true

                function updateValue(mx) {
                    let travel = width - thumb.width;
                    let ratio = Math.max(0, Math.min(1, (mx - thumb.width / 2) / travel));
                    let nextVal = Math.round(ratio * 100);
                    
                    if (nextVal !== root.value) {
                        root.userChanged(nextVal);
                    }
                }

                onPressed:         mouse => updateValue(mouse.x)
                onPositionChanged: mouse => { if (pressed) updateValue(mouse.x) }
            }
        }
    }
}