pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.Reusables.Theme

Rectangle {
    id: root
    
    // Styling (fixed)
    color: Theme.color.bg2
    radius: Theme.radius.lg
    height: Theme.height.sm
    
    // Layout computation
    implicitWidth: contentLayout.implicitWidth + Theme.padding.md
    
    // Allow child elements to be added
    default property alias content: contentLayout.children
    
    RowLayout {
        id: contentLayout
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 0
        anchors.rightMargin: Theme.padding.xs
        spacing: Theme.spacing.sm
    }
}