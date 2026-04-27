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
    
    // Layout computation - account for padding on both sides
    implicitWidth: contentLayout.implicitWidth + Theme.padding.sm
    
    // Allow child elements to be added
    default property alias content: contentLayout.children
    
    // Expose mouseArea for configuration
    property alias mouseArea: mouseAreaImpl
    
    RowLayout {
        id: contentLayout
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 0
        spacing: Theme.spacing.sm
    }
    
    MouseArea {
        id: mouseAreaImpl
        anchors.fill: parent
        enabled: false
    }
}