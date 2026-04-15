pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.Reusables

Item {
    property string icon:  ""
    property string label: ""
    property int    value: 0
    signal userChanged(int val)

    implicitHeight: sliderCol.implicitHeight

    Column {
        id:      sliderCol
        width:   parent.width
        spacing: 6

        RowLayout {
            width: parent.width

            MdIcons {
                text:     icon
                iconSize: 14
                color:    Theme.color.fg1
            }

            Text {
                text:             label
                Layout.fillWidth: true
                color:            Theme.color.fg1
                font.pixelSize:   12
                font.family:      Theme.font.ui
            }

            Text {
                text:           value + "%"
                color:          Theme.color.fg2
                font.pixelSize: 11
                font.family:    Theme.font.ui
            }
        }

        Item {
            width:  parent.width
            height: 15

            Rectangle {
                anchors.fill: parent
                radius:       11
                color:        Theme.color.bg3
            }

            Rectangle {
                width:  Math.max(radius * 2, parent.width * (value / 100))
                height: parent.height
                radius: 11
                color:  Theme.color.accent0

                Behavior on width {
                    enabled: !trackMouse.pressed
                    NumberAnimation { duration: 80; easing.type: Easing.OutQuad }
                }
            }

            Rectangle {
                x:            Math.max(0, Math.min(parent.width - width,
                                  parent.width * (value / 100) - width / 2))
                y:            (parent.height - height) / 2
                width:        12
                height:       30
                radius:       5
                color:        Theme.color.fg0
                border.color: Theme.color.bg0
                border.width: 4

                Rectangle {
                    anchors.centerIn: parent
                    width:        parent.width  + 4
                    height:       parent.height + 4
                    radius:       parent.radius + 2
                    color:        "transparent"
                    border.color: "transparent"
                    border.width: 2
                    z:            -1
                }

                Behavior on x {
                    enabled: !trackMouse.pressed
                    NumberAnimation { duration: 80; easing.type: Easing.OutQuad }
                }
            }

            MouseArea {
                id:           trackMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape:  Qt.PointingHandCursor

                function valueAt(mx) {
                    return Math.max(0, Math.min(100, Math.round(mx / width * 100)))
                }

                onPressed:         mouse => userChanged(valueAt(mouse.x))
                onPositionChanged: mouse => { if (pressed) userChanged(valueAt(mouse.x)) }
            }
        }
    }
}