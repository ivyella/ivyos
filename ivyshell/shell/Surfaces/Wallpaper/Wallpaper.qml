pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import QtQuick.Shapes
import Quickshell.Wayland
import qs.Reusables.Theme
import qs.Services.Config

Variants {
    model: Quickshell.screens
    delegate: WlrLayershell {
        id: wpShell
        required property var modelData
        namespace: "wallpaper"
        screen: modelData
        exclusionMode: ExclusionMode.Ignore
        
        anchors {
            left: true
            top: true
            bottom: true
            right: true
        }

        layer: WlrLayer.Background

        Image {
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            source: Config.currentWallpaper
            mipmap: true
        }
    }
}