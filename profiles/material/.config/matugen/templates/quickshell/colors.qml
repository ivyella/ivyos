pragma Singleton
import Quickshell
import QtQuick

Item {
    id: colors

    /* =========================
     * Core surfaces
     * ========================= */
    property color background: "{{colors.background.default.hex}}"

    property color surface: "{{colors.surface.default.hex}}"
    property color surfaceDim: "{{colors.surface_dim.default.hex}}"
    property color surfaceBright: "{{colors.surface_bright.default.hex}}"

    property color surfaceContainerLowest: "{{colors.surface_container_lowest.default.hex}}"
    property color surfaceContainerLow: "{{colors.surface_container_low.default.hex}}"
    property color surfaceContainer: "{{colors.surface_container.default.hex}}"
    property color surfaceContainerHigh: "{{colors.surface_container_high.default.hex}}"
    property color surfaceContainerHighest: "{{colors.surface_container_highest.default.hex}}"

    property color surfaceVariant: "{{colors.surface_variant.default.hex}}"
    property color surfaceTint: "{{colors.surface_tint.default.hex}}"

    /* =========================
     * Primary / Secondary / Tertiary
     * ========================= */
    property color primary: "{{colors.primary.default.hex}}"
    property color primaryContainer: "{{colors.primary_container.default.hex}}"
    property color primaryFixed: "{{colors.primary_fixed.default.hex}}"
    property color primaryFixedDim: "{{colors.primary_fixed_dim.default.hex}}"

    property color secondary: "{{colors.secondary.default.hex}}"
    property color secondaryContainer: "{{colors.secondary_container.default.hex}}"
    property color secondaryFixed: "{{colors.secondary_fixed.default.hex}}"
    property color secondaryFixedDim: "{{colors.secondary_fixed_dim.default.hex}}"

    property color tertiary: "{{colors.tertiary.default.hex}}"
    property color tertiaryContainer: "{{colors.tertiary_container.default.hex}}"
    property color tertiaryFixed: "{{colors.tertiary_fixed.default.hex}}"
    property color tertiaryFixedDim: "{{colors.tertiary_fixed_dim.default.hex}}"

    /* =========================
     * Error
     * ========================= */
    property color error: "{{colors.error.default.hex}}"
    property color errorContainer: "{{colors.error_container.default.hex}}"

    /* =========================
     * Text / foreground colors
     * (formerly onX — QML-safe)
     * ========================= */
    property color textOnBackground: "{{colors.on_background.default.hex}}"
    property color textOnSurface: "{{colors.on_surface.default.hex}}"
    property color textOnSurfaceVariant: "{{colors.on_surface_variant.default.hex}}"

    property color textOnPrimary: "{{colors.on_primary.default.hex}}"
    property color textOnPrimaryContainer: "{{colors.on_primary_container.default.hex}}"
    property color textOnPrimaryFixed: "{{colors.on_primary_fixed.default.hex}}"
    property color textOnPrimaryFixedVariant: "{{colors.on_primary_fixed_variant.default.hex}}"

    property color textOnSecondary: "{{colors.on_secondary.default.hex}}"
    property color textOnSecondaryContainer: "{{colors.on_secondary_container.default.hex}}"
    property color textOnSecondaryFixed: "{{colors.on_secondary_fixed.default.hex}}"
    property color textOnSecondaryFixedVariant: "{{colors.on_secondary_fixed_variant.default.hex}}"

    property color textOnTertiary: "{{colors.on_tertiary.default.hex}}"
    property color textOnTertiaryContainer: "{{colors.on_tertiary_container.default.hex}}"
    property color textOnTertiaryFixed: "{{colors.on_tertiary_fixed.default.hex}}"
    property color textOnTertiaryFixedVariant: "{{colors.on_tertiary_fixed_variant.default.hex}}"

    property color textOnError: "{{colors.on_error.default.hex}}"
    property color textOnErrorContainer: "{{colors.on_error_container.default.hex}}"

    /* =========================
     * Inverse
     * ========================= */
    property color inverseSurface: "{{colors.inverse_surface.default.hex}}"
    property color inversePrimary: "{{colors.inverse_primary.default.hex}}"
    property color inverseText: "{{colors.inverse_on_surface.default.hex}}"

    /* =========================
     * Utility
     * ========================= */
    property color outline: "{{colors.outline.default.hex}}"
    property color outlineVariant: "{{colors.outline_variant.default.hex}}"

    property color shadow: "{{colors.shadow.default.hex}}"
    property color scrim: "{{colors.scrim.default.hex}}"

    /* =========================
     * Source (matugen reference)
     * ========================= */
    property color sourceColor: "{{colors.source_color.default.hex}}"
}
