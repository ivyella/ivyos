pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.Reusables.Theme

Rectangle {
    id: root

    // Styling
    color: Theme.color.bg2
    radius: Theme.radius.lg
    height: Theme.height.sm

    // FIX: symmetric padding, no magic numbers
    implicitWidth: contentLayout.implicitWidth + Theme.padding.sm 

    default property alias content: contentLayout.children
    property alias mouseArea: mouseAreaImpl

    RowLayout {
        id: contentLayout

        anchors.verticalCenter: parent.verticalCenter

        // IMPORTANT: give layout real padding control instead of manual anchoring
        anchors.leftMargin: Theme.padding.sm
        anchors.rightMargin: Theme.padding.sm

        spacing: Theme.spacing.sm
    }

    MouseArea {
        id: mouseAreaImpl
        anchors.fill: parent
        enabled: false
    }
}