// NavItem.qml
import QtQuick
import QtQuick.Layouts
import qs.Reusables.Theme
import qs.Reusables.MdIcons

Rectangle {
    id: navItem

    property string label: ""
    property string page: ""
    property string icon: ""
    property string activePage: ""

    signal activate()

    readonly property bool isActive: activePage === page

    Layout.fillWidth: true
    implicitHeight: 36
    radius: Theme.radius.sm
    color: isActive ? Theme.color.bg3 : hover.containsMouse ? Theme.color.bg2 : "transparent"

    Rectangle {
        width: 3
        height: 16
        radius: 2
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.color.accent0
        visible: navItem.isActive
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacing.md
        anchors.rightMargin: Theme.spacing.md
        spacing: Theme.spacing.sm

        MdIcons {
            iconSize: Theme.font.md
            text: navItem.icon
            color: navItem.isActive ? Theme.color.fg0 : Theme.color.fg2
        }

        Text {
            Layout.fillWidth: true
            text: navItem.label
            color: navItem.isActive ? Theme.color.fg0 : Theme.color.fg2
            font.pixelSize: Theme.font.sm
            font.family: Theme.font.ui
        }
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: navItem.activate()
    }
}
