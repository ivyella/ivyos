pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Shapes
import qs.Common

Variants {
    model: Quickshell.screens
    delegate: PanelWindow {
        required property var modelData
        screen: modelData

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        mask: Region{}

        Item {
            anchors.fill: parent
            Item {
                anchors.fill: parent
                layer.enabled: true

                Shape {
                    id: cornersShape
                    anchors.fill: parent
                    preferredRendererType: Shape.CurveRenderer
                    enabled: false

                    ShapePath {
                        id: cornersPath

                        readonly property color cornerColor: Colors.background
                        readonly property real cornerRadius: 10
                        readonly property real cornerSize: 10
                        readonly property real topMargin: 30
                        readonly property real bottomMargin: 0
                        readonly property real leftMargin: 0
                        readonly property real rightMargin: 0
                        readonly property real screenWidth: cornersShape.width
                        readonly property real screenHeight: cornersShape.height

                        strokeWidth: -1
                        fillColor: cornerColor

                        // TOP-LEFT
                        startX: leftMargin
                        startY: topMargin
                        PathLine { relativeX: cornersPath.cornerSize; relativeY: 0 }
                        PathLine { relativeX: 0; relativeY: cornersPath.cornerSize - cornersPath.cornerRadius }
                        PathArc {
                            relativeX: -cornersPath.cornerRadius
                            relativeY: cornersPath.cornerRadius
                            radiusX: cornersPath.cornerRadius
                            radiusY: cornersPath.cornerRadius
                            direction: PathArc.Counterclockwise
                        }
                        PathLine { relativeX: -(cornersPath.cornerSize - cornersPath.cornerRadius); relativeY: 0 }
                        PathLine { relativeX: 0; relativeY: -cornersPath.cornerSize }

                        // TOP-RIGHT
                        PathMove {
                            x: cornersPath.screenWidth - cornersPath.rightMargin - cornersPath.cornerSize
                            y: cornersPath.topMargin
                        }
                        PathLine { relativeX: cornersPath.cornerSize; relativeY: 0 }
                        PathLine { relativeX: 0; relativeY: cornersPath.cornerSize }
                        PathLine { relativeX: -(cornersPath.cornerSize - cornersPath.cornerRadius); relativeY: 0 }
                        PathArc {
                            relativeX: -cornersPath.cornerRadius
                            relativeY: -cornersPath.cornerRadius
                            radiusX: cornersPath.cornerRadius
                            radiusY: cornersPath.cornerRadius
                            direction: PathArc.Counterclockwise
                        }
                        PathLine { relativeX: 0; relativeY: -(cornersPath.cornerSize - cornersPath.cornerRadius) }

                        // BOTTOM-LEFT
                        PathMove {
                            x: cornersPath.leftMargin
                            y: cornersPath.screenHeight - cornersPath.bottomMargin - cornersPath.cornerSize
                        }
                        PathLine { relativeX: cornersPath.cornerSize - cornersPath.cornerRadius; relativeY: 0 }
                        PathArc {
                            relativeX: cornersPath.cornerRadius
                            relativeY: cornersPath.cornerRadius
                            radiusX: cornersPath.cornerRadius
                            radiusY: cornersPath.cornerRadius
                            direction: PathArc.Counterclockwise
                        }
                        PathLine { relativeX: 0; relativeY: cornersPath.cornerSize - cornersPath.cornerRadius }
                        PathLine { relativeX: -cornersPath.cornerSize; relativeY: 0 }
                        PathLine { relativeX: 0; relativeY: -cornersPath.cornerSize }

                        // BOTTOM-RIGHT
                        PathMove {
                            x: cornersPath.screenWidth - cornersPath.rightMargin
                            y: cornersPath.screenHeight - cornersPath.bottomMargin
                        }
                        PathLine { relativeX: -cornersPath.cornerSize; relativeY: 0 }
                        PathLine { relativeX: 0; relativeY: -(cornersPath.cornerSize - cornersPath.cornerRadius) }
                        PathArc {
                            relativeX: cornersPath.cornerRadius
                            relativeY: -cornersPath.cornerRadius
                            radiusX: cornersPath.cornerRadius
                            radiusY: cornersPath.cornerRadius
                            direction: PathArc.Counterclockwise
                        }
                        PathLine { relativeX: cornersPath.cornerSize - cornersPath.cornerRadius; relativeY: 0 }
                        PathLine { relativeX: 0; relativeY: cornersPath.cornerSize }
                    }
                }
            }
        }
    }
}