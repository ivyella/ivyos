import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import qs.Reusables.Theme
import qs.Reusables.Components

PanelWindow {
    id: root

    // --- Properties ---
    required property var modelData

    property real  thickness:    3
    property real  cornerRadius: 12
    property real  borderWidth:  2 // Thinner borders often look cleaner on panels
    property color borderColor:  Theme.color.bg3
    property color fillColor:    Theme.color.bg0

    // --- Window Configuration ---
    screen: modelData
    aboveWindows: true
    focusable: false
    color: "transparent"
    exclusiveZone: 0
    
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    // --- Click-Through Masking ---
    // Using a single source of truth for the viewport geometry
    mask: Region {
        item: fullArea
        intersection: Intersection.Subtract
        Region { item: viewportArea }
    }

    // Reference items for the mask (invisible)
    Item { id: fullArea; anchors.fill: parent }
    
    Rectangle {
        id: viewportArea
        x: root.thickness
        y: root.thickness
        width: root.width - (root.thickness * 2)
        height: root.height - (root.thickness * 2)
        radius: root.cornerRadius
        visible: false
    }

    // --- Visuals ---
    Shape {
        id: frameShape
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 8 // High quality anti-aliasing
        vendorExtensionsEnabled: true

        // 1. The Main Frame (The "Gasket")
        ShapePath {
            strokeWidth: 0
            fillColor: root.fillColor
            fillRule: ShapePath.OddEvenFill

            PathRectangle { 
                width: root.width
                height: root.height 
            }
            
            PathRectangle {
                x: root.thickness
                y: root.thickness
                width: root.width - (root.thickness * 2)
                height: root.height - (root.thickness * 2)
                radius: root.cornerRadius
            }
        }

        // 2. The Inner Border Line
        // Simplified math: Center the stroke on the edge of the thickness
        ShapePath {
            strokeWidth: root.borderWidth
            strokeColor: root.borderColor
            fillColor: "transparent"
            
            // RoundJoin prevents "sharp" outer artifacts on the stroke
            joinStyle: ShapePath.RoundJoin 

            PathRectangle {
                x: root.thickness
                y: root.thickness
                width: root.width - (root.thickness * 2)
                height: root.height - (root.thickness * 2)
                radius: root.cornerRadius
            }
        }
    }
}