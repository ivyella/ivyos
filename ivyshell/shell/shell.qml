//@ pragma ShellId ivyshell
//@ pragma UseQApplication
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick  

import qs.Overlays.Launcher
import qs.Overlays.NotificationCard
import qs.Overlays.PowerMenu
import qs.Overlays.QuickPanel
import qs.Overlays.TrayMenu
import qs.Overlays.Osd

import qs.Reusables.Components
import qs.Reusables.Displays
import qs.Reusables.MdIcons
import qs.Reusables.Theme

import qs.Services 

import qs.Services.Config
import qs.Services.NiriOutputs
import qs.Services.Notification
import qs.Services.Time
import qs.Services.Battery

import qs.Surfaces.Bar
import qs.Surfaces.Settings
import qs.Surfaces.Wallpaper

import qs.Overlays.Dock


ShellRoot {
    Bar {}
    Notification {} 
    Wallpaper {}
    VolumeOSD { id: volumeOSD }   
    BrightnessOSD { id: brightnessOSD }  
    //MediaOSD { id: mediaOSD }  

    Dock {
        
    }
    readonly property var _powerMenu:  PowerMenu
    readonly property var _launcher:   Launcher
    readonly property var _settings:   Settings
    readonly property var _quickPanel: QuickPanel
}
