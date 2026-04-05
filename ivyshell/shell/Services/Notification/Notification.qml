pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Overlays
import qs.Reusables
import qs.Surfaces
import qs.Services
import qs.Services.Notification

Variants {
    model: Quickshell.screens
    delegate: WlrLayershell {
        id: root
        required property var modelData
        screen: modelData
        visible: modelData.name === Displays.primary
        
        anchors {
            top: true
            right: true
            bottom: true
        }

        margins {
            top: 40
            right: 10
            left: 10
        }

        mask: Region {
            item: notifList
        }

        implicitHeight: notifList.contentHeight + 20
        implicitWidth: 360
        layer: WlrLayer.Overlay
        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        ListView {
            id: notifList
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 10
            height: contentHeight
            model: NotiServer.trackedNotifications
            delegate: NotificationCard {}

            add: Transition {
                NumberAnimation {
                    property: "x"
                    from: notifList.width
                    to: 0
                    duration: 400
                    easing.type: Easing.OutExpo
                }
            }
            remove: Transition {
                NumberAnimation {
                    property: "x"
                    from: 0
                    to: notifList.width
                    duration: 400
                    easing.type: Easing.OutExpo
                }
            }
            move: Transition {
                NumberAnimation {
                    properties: "y"
                    duration: 300
                }
            }
        }
    }
}