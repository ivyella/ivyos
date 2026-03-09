pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property string configPath: Quickshell.env("HOME") + "/ivyos/ivyshell/shell/Config/config.json"
    property string currentTheme: "file://" + Quickshell.env("HOME") + "/ivyos/ivyshell/themes/colors/IvyTheme.json"
    property string currentVariant: "default"
    property string currentWallpaper: "file://" + Quickshell.env("HOME") + "/ivyos/ivyshell/themes/wallpapers/a_group_of_trees_with_green_leaves.jpg"

    FileView {
        id: file
        path: root.configPath
        blockLoading: true

        JsonAdapter {
            id: adapter
            property string theme
            property string variant
            property string wallpaper
        }

        onLoaded: {
            if (adapter.theme)     root.currentTheme     = adapter.theme
            if (adapter.variant)   root.currentVariant   = adapter.variant
            if (adapter.wallpaper) root.currentWallpaper = adapter.wallpaper
        }

        onLoadFailed: root.save()
        Component.onCompleted: reload()
    }

    function save() {
        adapter.theme     = root.currentTheme
        adapter.variant   = root.currentVariant
        adapter.wallpaper = root.currentWallpaper
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
}
