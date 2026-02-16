//@ pragma UseQApplication

import Quickshell
import Quickshell.Wayland
import qs.Bar
import qs.Corners
import qs.Notification
import qs.Wallpaper
import qs.Ipc
import Quickshell.Io  

ShellRoot {
    Bar{}
    ScreenCorners {}
    Notification {}
    Ipc {}
    Wallpaper {}
} 