pragma Singleton
import Quickshell
import QtQuick

Item {
    id: colors

    /* =========================
     * Core surfaces
     * ========================= */
    property color background: "#101417"

    property color surface: "#101417"
    property color surfaceDim: "#101417"
    property color surfaceBright: "#353a3d"

    property color surfaceContainerLowest: "#0a0f12"
    property color surfaceContainerLow: "#181c20"
    property color surfaceContainer: "#1c2024"
    property color surfaceContainerHigh: "#262a2e"
    property color surfaceContainerHighest: "#313539"

    property color surfaceVariant: "#41484d"
    property color surfaceTint: "#92cef6"

    /* =========================
     * Primary / Secondary / Tertiary
     * ========================= */
    property color primary: "#92cef6"
    property color primaryContainer: "#004c6c"
    property color primaryFixed: "#c7e7ff"
    property color primaryFixedDim: "#92cef6"

    property color secondary: "#b6c9d8"
    property color secondaryContainer: "#374955"
    property color secondaryFixed: "#d2e5f5"
    property color secondaryFixedDim: "#b6c9d8"

    property color tertiary: "#ccc0e9"
    property color tertiaryContainer: "#4a4263"
    property color tertiaryFixed: "#e8ddff"
    property color tertiaryFixedDim: "#ccc0e9"

    /* =========================
     * Error
     * ========================= */
    property color error: "#ffb4ab"
    property color errorContainer: "#93000a"

    /* =========================
     * Text / foreground colors
     * (formerly onX — QML-safe)
     * ========================= */
    property color textOnBackground: "#dfe3e7"
    property color textOnSurface: "#dfe3e7"
    property color textOnSurfaceVariant: "#c1c7ce"

    property color textOnPrimary: "#00344c"
    property color textOnPrimaryContainer: "#c7e7ff"
    property color textOnPrimaryFixed: "#001e2e"
    property color textOnPrimaryFixedVariant: "#004c6c"

    property color textOnSecondary: "#21323e"
    property color textOnSecondaryContainer: "#d2e5f5"
    property color textOnSecondaryFixed: "#0b1d29"
    property color textOnSecondaryFixedVariant: "#374955"

    property color textOnTertiary: "#342b4b"
    property color textOnTertiaryContainer: "#e8ddff"
    property color textOnTertiaryFixed: "#1e1635"
    property color textOnTertiaryFixedVariant: "#4a4263"

    property color textOnError: "#690005"
    property color textOnErrorContainer: "#ffdad6"

    /* =========================
     * Inverse
     * ========================= */
    property color inverseSurface: "#dfe3e7"
    property color inversePrimary: "#226487"
    property color inverseText: "#2d3135"

    /* =========================
     * Utility
     * ========================= */
    property color outline: "#8b9198"
    property color outlineVariant: "#41484d"

    property color shadow: "#000000"
    property color scrim: "#000000"

    /* =========================
     * Source (matugen reference)
     * ========================= */
    property color sourceColor: "#3a434a"
}
