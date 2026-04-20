pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.Reusables.Theme
import qs.Reusables.MdIcons

Rectangle {
    property string icon:   ""
    property string label:  ""
    property bool   active: false
    signal toggled()

    height:       56
    radius:       Theme.radius.md
    color:        active
                  ? Qt.rgba(Theme.color.accent0.r, Theme.color.accent0.g, Theme.color.accent0.b, 0.18)
                  : (tileHover.containsMouse ? Theme.color.bg3 : Theme.color.bg2)
    border.color: active ? Theme.color.accent0 : Theme.color.border0
    border.width: 0

    Behavior on color        { ColorAnimation { duration: 140 } }
    Behavior on border.color { ColorAnimation { duration: 140 } }

    Column {
        anchors {
            left:    parent.left
            top:     parent.top
            right:   parent.right
            margins: 10
        }
        spacing: 4

        MdIcons {
            text:     icon
            iconSize: 16
            fill:     active ? 1 : 0
            color:    active ? Theme.color.accent0 : Theme.color.fg1
        }

        Text {
            text:           label
            width:          parent.width
            color:          active ? Theme.color.accent0 : Theme.color.fg0
            font.pixelSize: 11
            font.family:    Theme.font.ui
            font.weight:    Font.Medium
            elide:          Text.ElideRight
        }
    }

    MouseArea {
        id:           tileHover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape:  Qt.PointingHandCursor
        onPressed:    mouse => mouse.accepted = true
        onClicked:    mouse => { mouse.accepted = true; toggled() }
    }
}