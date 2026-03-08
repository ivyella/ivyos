import QtQuick
import qs.Common

Text {
    id: root
    color: Theme.color.fg0
    property real iconSize: 16
    property real fill: 1
    renderType: Text.NativeRendering
    font {
        hintingPreference: Font.PreferNoHinting
        family: "Material Symbols Rounded"
        pixelSize: iconSize
        weight: Font.Normal + (Font.DemiBold - Font.Normal) * fill
        variableAxes: ({
            "FILL": fill.toFixed(1),
            "opsz": iconSize
        })
    }
}