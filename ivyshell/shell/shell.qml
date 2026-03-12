//@ pragma UseQApplication

import Quickshell
import Quickshell.Wayland
import qs.Bar
import qs.Notification
import qs.Wallpaper
import qs.Ipc
import Quickshell.Io  
import qs.Test
import qs.PowerMenu 
import qs.Config
import qs.ThemeSwitcher
import qs.Launcher
import qs.TrayMenu
import qs.NotificationHistory

ShellRoot {
    Bar{}
    Notification {}
    Ipc {}
    Wallpaper {}
    TestOverlay {}
    readonly property var _themeSwitcher: ThemeSwitcher
    readonly property var _powerMenu: PowerMenu
    readonly property var _launcher: Launcher
} 