pragma ComponentBehavior: Bound
import Quickshell
import QtQuick
import Quickshell.Wayland
import qs.Wallpaper

Variants {
    model: Quickshell.screens
    delegate: WlrLayershell {
        id: wpShell
        
        // This is the critical line that matches your Niri config:
        namespace: "wallpaper" 
        
        screen: modelData

        exclusionMode: ExclusionMode.Ignore
        
        // Use anchors to fill the screen surface properly
        anchors {
            left: true
            top: true
            bottom: true
            right: true
        }

        layer: WlrLayer.Background

        Image {
            anchors.fill: parent // Simplified: fill the shell surface
            fillMode: Image.PreserveAspectCrop
            source: WallSwitcher.currentWall
            
            // Optional: Smooths out the image when scaled
            mipmap: true 
        }
    }
}