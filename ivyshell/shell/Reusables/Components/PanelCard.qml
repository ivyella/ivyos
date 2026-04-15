pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.Reusables

Rectangle {
    id: card

    property string title:             ""
    property string icon:              ""
    property bool   isExpanded:        true
    property bool   headerButton:      false
    property string headerButtonLabel: ""
    signal headerClicked()
    signal headerButtonClicked()
    default property alias contents: bodyCol.children

    implicitHeight: headerRow.height
                    + (isExpanded ? bodyCol.implicitHeight + 20 : 0)
                    + 20
    radius:       Theme.radius.lg
    color:        Theme.color.bg0
    border.color: Theme.color.border0
    border.width: 1
    clip:         true

    Behavior on implicitHeight {
        NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
    }

    Item {
        id:     headerRow
        width:  parent.width
        height: 44

        RowLayout {
            anchors {
                fill:        parent
                leftMargin:  14
                rightMargin: 14
            }
            spacing: 8

            MdIcons {
                text:     card.icon
                color:    Theme.color.accent0
                iconSize: 16
                fill:     1
            }

            Text {
                text:             card.title
                Layout.fillWidth: true
                color:            Theme.color.fg0
                font.pixelSize:   Theme.font.sm
                font.family:      Theme.font.ui
                font.weight:      Font.Medium
            }

            Rectangle {
                width:   52
                height:  22
                radius:  11
                visible: card.headerButton
                color:   clearHover.containsMouse
                         ? Theme.color.accent0
                         : Theme.color.bg2

                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text:             card.headerButtonLabel
                    color:            clearHover.containsMouse
                                      ? Theme.color.bg0
                                      : Theme.color.fg1
                    font.pixelSize:   10
                    font.family:      Theme.font.ui
                }

                MouseArea {
                    id:           clearHover
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    onPressed:    mouse => mouse.accepted = true
                    onClicked:    mouse => {
                        mouse.accepted = true
                        card.headerButtonClicked()
                    }
                }
            }

            MdIcons {
                text:     card.isExpanded ? "expand_less" : "expand_more"
                color:    Theme.color.fg2
                iconSize: 16
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape:  Qt.PointingHandCursor
            z:            -1
            onPressed:    mouse => mouse.accepted = true
            onClicked:    mouse => {
                mouse.accepted = true
                card.headerClicked()
            }
        }
    }

    Column {
        id: bodyCol
        anchors {
            top:          headerRow.bottom
            left:         parent.left
            right:        parent.right
            leftMargin:   14
            rightMargin:  14
            bottomMargin: 14
        }
        spacing: 8
        opacity: card.isExpanded ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 180 } }
    }
}