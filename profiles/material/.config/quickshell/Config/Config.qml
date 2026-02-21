pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    readonly property string configPath: Quickshell.env("HOME") + "/ivyos/profiles/material/.config/quickshell/Config/config.json"

    property string currentTheme: "file:///home/ivy/ivyos/profiles/material/.config/quickshell/Common/Themes/IvyTheme.json" // Default filename (without .qml)
    property string currentWallpaper: "file:///home/ivy/ivyos/themes/wallpapers/a_group_of_trees_with_green_leaves.jpg"

    FileView {
        id: file
        path: root.configPath
        blockLoading: true

        JsonAdapter {
            id: adapter
            property string theme
            property string wallpaper
        }

        onLoaded: {
            if (adapter.theme) root.currentTheme = adapter.theme;
            if (adapter.wallpaper) root.currentWallpaper = adapter.wallpaper;
        }

        onLoadFailed: root.save()

        Component.onCompleted: reload()
    }

    function save() {
        adapter.theme = root.currentTheme
        adapter.wallpaper = root.currentWallpaper
        file.writeAdapter()
    }

    function setTheme(path) {
        root.currentTheme = path
        save()
    }

    function setWallpaper(path) {
        root.currentWallpaper = path
        save()
    }
}