pragma Singleton
import Quickshell
import QtQuick

Item {
    id: colors

    /* =========================
     * Core surfaces
     * ========================= */
    property color background: "#13140d"

    property color surface: "#13140d"
    property color surfaceDim: "#13140d"
    property color surfaceBright: "#393a31"

    property color surfaceContainerLowest: "#0e0f08"
    property color surfaceContainerLow: "#1b1c14"
    property color surfaceContainer: "#202018"
    property color surfaceContainerHigh: "#2a2b22"
    property color surfaceContainerHighest: "#35352d"

    property color surfaceVariant: "#47483b"
    property color surfaceTint: "#c3cd7c"

    /* =========================
     * Primary / Secondary / Tertiary
     * ========================= */
    property color primary: "#c3cd7c"
    property color primaryContainer: "#434b05"
    property color primaryFixed: "#dfe995"
    property color primaryFixedDim: "#c3cd7c"

    property color secondary: "#c7c9a7"
    property color secondaryContainer: "#46492f"
    property color secondaryFixed: "#e3e5c2"
    property color secondaryFixedDim: "#c7c9a7"

    property color tertiary: "#a2d0c2"
    property color tertiaryContainer: "#224e43"
    property color tertiaryFixed: "#beecdd"
    property color tertiaryFixedDim: "#a2d0c2"

    /* =========================
     * Error
     * ========================= */
    property color error: "#ffb4ab"
    property color errorContainer: "#93000a"

    /* =========================
     * Text / foreground colors
     * (formerly onX — QML-safe)
     * ========================= */
    property color textOnBackground: "#e5e3d6"
    property color textOnSurface: "#e5e3d6"
    property color textOnSurfaceVariant: "#c8c7b7"

    property color textOnPrimary: "#2e3400"
    property color textOnPrimaryContainer: "#dfe995"
    property color textOnPrimaryFixed: "#1a1e00"
    property color textOnPrimaryFixedVariant: "#434b05"

    property color textOnSecondary: "#2f321a"
    property color textOnSecondaryContainer: "#e3e5c2"
    property color textOnSecondaryFixed: "#1a1d07"
    property color textOnSecondaryFixedVariant: "#46492f"

    property color textOnTertiary: "#06372d"
    property color textOnTertiaryContainer: "#beecdd"
    property color textOnTertiaryFixed: "#002019"
    property color textOnTertiaryFixedVariant: "#224e43"

    property color textOnError: "#690005"
    property color textOnErrorContainer: "#ffdad6"

    /* =========================
     * Inverse
     * ========================= */
    property color inverseSurface: "#e5e3d6"
    property color inversePrimary: "#5b631e"
    property color inverseText: "#303128"

    /* =========================
     * Utility
     * ========================= */
    property color outline: "#929283"
    property color outlineVariant: "#47483b"

    property color shadow: "#000000"
    property color scrim: "#000000"

    /* =========================
     * Source (matugen reference)
     * ========================= */
    property color sourceColor: "#61634d"
}
