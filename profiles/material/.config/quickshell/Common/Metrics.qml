pragma Singleton
import QtQuick

QtObject {
    /* =========================
     * Padding
     * ========================= */
    property int paddingXs: 4
    property int paddingSm: 6
    property int paddingMd: 8
    property int paddingLg: 12
    property int paddingXl: 16

    /* =========================
     * Spacing (between elements)
     * ========================= */
    property int spacingXs: 4
    property int spacingSm: 6
    property int spacingMd: 8
    property int spacingLg: 12

    /* =========================
     * Margins
     * ========================= */

    property int marginXXs: 0
    property int marginXs: 4
    property int marginSm: 8
    property int marginMd: 12
    property int marginLg: 16
    property int marginXl: 20
    property int marginXXl: 24

    /* =========================
     * Control sizes (heights)
     * ========================= */
    property int controlHeightSm: 22
    property int controlHeight: 26
    property int controlHeightLg: 30

    /* =========================
     * Icon sizes
     * ========================= */
    property int iconSizeSm: 14
    property int iconSize: 16
    property int iconSizeLg: 18

    /* =========================
     * Corner radius
     * ========================= */
    property int radiusXs: 4
    property int radiusSm: 6
    property int radiusMd: 8
    property int radiusLg: 12

    /* =========================
     * Font sizes
     * ========================= */
    property int fontSizeSm: 10
    property int fontSize: 12
    property int fontSizeLg: 14
    property int fontSizeXl: 16

    /* =========================
     * Font family / weight defaults
     * ========================= */
    property string fontFamily: "Open Sans"
    property bool fontBold: true
}
