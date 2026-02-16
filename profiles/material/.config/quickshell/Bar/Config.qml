pragma Singleton
import QtQuick
import qs.Common

QtObject {

    property int capsuleMargin: 16 // inner margin for text elements in capsules
    property int borderRadius: 12
    property int capsuleHeight: 22
    property var backgroundColor: Colors.background
    property var fontFamily: Metrics.fontFamily
    property int fontSizeSmall: 10
    property int fontSizeNormal: 12
    property int fontSizeLarge: 14
    property var fontColorPrimary: Colors.textOnSurface
    property var fontColorSecondary: Colors.textOnSurfaceVariant
    property var accentDeep:  "#727459"

}
