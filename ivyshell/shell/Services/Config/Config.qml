pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property string configPath: Quickshell.env("HOME") + "/ivyos/ivyshell/shell/Services/Config/config.json"

    // ── Theme ─────────────────────────────────────────────────────────────────
    property string currentTheme:    "file://" + Quickshell.env("HOME") + "/ivyos/ivyshell/themes/colors/IvyTheme.json"
    property string currentVariant:  "default"
    property string currentWallpaper: "file://" + Quickshell.env("HOME") + "/ivyos/ivyshell/themes/wallpapers/a_group_of_trees_with_green_leaves.jpg"

    // ── Font ──────────────────────────────────────────────────────────────────
    property string fontUi:     "JetBrains Mono"
    property string fontMono:   "JetBrains Mono"
    property real   fontScale:  1.0
    property int    fontWeight: 400

    // ── UI ────────────────────────────────────────────────────────────────────
    property real uiScale:      1.0
    property real borderRadius: 12

    // ── Night Light ───────────────────────────────────────────────────────────
    property int nightLightTemp: 4000

    FileView {
        id: file
        path: root.configPath
        blockLoading: true

        JsonAdapter {
            id: adapter
            property string theme
            property string variant
            property string wallpaper
            property var    font
            property real   uiScale
            property real   borderRadius
            property var    nightLight
        }

        onLoaded: {
            if (adapter.theme)     root.currentTheme     = adapter.theme
            if (adapter.variant)   root.currentVariant   = adapter.variant
            if (adapter.wallpaper) root.currentWallpaper = adapter.wallpaper

            if (adapter.font) {
                if (adapter.font.ui)     root.fontUi     = adapter.font.ui
                if (adapter.font.mono)   root.fontMono   = adapter.font.mono
                if (adapter.font.scale)  root.fontScale  = adapter.font.scale
                if (adapter.font.weight) root.fontWeight = adapter.font.weight
            }

            if (adapter.uiScale)      root.uiScale      = adapter.uiScale
            if (adapter.borderRadius) root.borderRadius = adapter.borderRadius


            if (adapter.nightLight) {
                if (adapter.nightLight.temp) root.nightLightTemp = adapter.nightLight.temp
            }
        }

        onLoadFailed: root.save()
        Component.onCompleted: reload()
    }

    function save() {
        adapter.theme    = root.currentTheme
        adapter.variant  = root.currentVariant
        adapter.wallpaper = root.currentWallpaper
        adapter.font = {
            ui:     root.fontUi,
            mono:   root.fontMono,
            scale:  root.fontScale,
            weight: root.fontWeight
        }
        adapter.uiScale      = root.uiScale
        adapter.borderRadius = root.borderRadius
        adapter.nightLight = { temp: root.nightLightTemp }
        file.writeAdapter()
    }

    function setTheme(path, variant) {
        root.currentTheme   = path
        root.currentVariant = variant
        save()
    }

    function setWallpaper(path) {
        root.currentWallpaper = path
        save()
    }

    function setFont(ui, mono, scale, weight) {
        root.fontUi     = ui
        root.fontMono   = mono
        root.fontScale  = scale
        root.fontWeight = weight
        save()
    }

    function setBorderRadius(val) {
        root.borderRadius = val
        save()
    }

    function setUiScale(val) {
        root.uiScale = val
        save()
    }
}