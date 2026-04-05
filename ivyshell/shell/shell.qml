//@ pragma UseQApplication
import Quickshell
import Quickshell.Wayland
import Quickshell.Io


import qs.Overlays
import qs.Reusables
import qs.Surfaces
import qs.Services

ShellRoot {
    Bar {}
    Notification {}
    Wallpaper {}

    readonly property var _powerMenu:  PowerMenu
    readonly property var _launcher:   Launcher
    readonly property var _settings:   Settings
    readonly property var _quickPanel: QuickPanel
}