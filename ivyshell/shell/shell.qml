//@ pragma UseQApplication

import Quickshell
import Quickshell.Wayland
import qs.Bar
import qs.Notification
import qs.Wallpaper
import Quickshell.Io  
import qs.PowerMenu 
import qs.Config
import qs.Launcher
import qs.TrayMenu
import qs.NotificationHistory
import qs.Settings
import qs.ControlPanel
import qs.QuickPanel 

ShellRoot {
    Bar{}
    Notification {}
    Wallpaper {}
    readonly property var _themeSwitcher: ThemeSwitcher
    readonly property var _powerMenu: PowerMenu
    readonly property var _launcher: Launcher
    readonly property var _settings: Settings
    readonly property var _controlPanel: ControlPanel
    readonly property var _quickPanel: QuickPanel 
} 