pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.Reusables.Theme

Rectangle {
    id: root
    
    // Allow icon content (usually MdIcons)
    default property alias icon: iconContent.children
    
    // Styling (fixed)
    color: Theme.color.bg3
    radius: Theme.radius.lg
    height: Theme.height.sm
    width: Theme.height.sm
    
    Item {
        id: iconContent
        anchors.centerIn: parent
        width: Theme.height.sm - (Theme.padding.sm * 2)
        height: Theme.height.sm - (Theme.padding.sm * 2)
    }
}
