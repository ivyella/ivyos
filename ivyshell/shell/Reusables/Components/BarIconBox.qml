pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.Reusables.Theme

Rectangle {
    id: root
    
    // Allow icon content (usually MdIcons or Text)
    default property alias icon: iconContent.children
    
    // Styling (fixed)
    color: Theme.color.bg3
    radius: Theme.radius.lg
    height: Theme.height.sm
    width: Theme.height.sm
    
    Item {
        id: iconContent
        anchors.fill: parent
        anchors.margins: Theme.padding.sm
        
        // Center all children
        onChildrenChanged: {
            for (let child of children) {
                child.anchors.centerIn = iconContent
            }
        }
    }
}
