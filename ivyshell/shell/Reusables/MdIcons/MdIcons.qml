import QtQuick
import qs.Reusables.Theme

Text {
    id: root
    color: Theme.color.fg1
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