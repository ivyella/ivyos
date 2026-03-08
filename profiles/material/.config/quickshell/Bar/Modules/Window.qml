import Quickshell
import Quickshell.Io
import QtQuick
import qs.Bar
import qs.Common

Rectangle {
    id: windowCapsule
    color: Theme.color.bg2
    radius: Theme.radius.lg
    height: Theme.height.sm
    implicitWidth: activeWindowText.implicitWidth + Theme.padding.md * 2

    property string activeWindow: ""

    Text {
        id: activeWindowText
        anchors.centerIn: parent
        text: windowCapsule.activeWindow
        color: Theme.color.fg0
        font.pixelSize: Theme.font.sm
        font.family: Theme.font.ui
        font.weight: Theme.font.normal
    }

    Process {
        id: windowProc
        command: ["sh", "-c", "niri msg focused-window | grep 'App ID:' | awk -F '\"' '{print $2}'"]
        stdout: SplitParser {
            onRead: data => {
                if (!data || !data.trim()) return;
                const appId = data.trim();
                const names = {
                    "kitty": "Terminal",
                    "librewolf": "LibreWolf",
                    "dev.zed.Zed": "Zed",
                    "org.gnome.Nautilus": "Files",
                    "org.vinegarhq.Sober": "Roblox",
                    "spotify": "Spotify",
                    "steam": "Steam",
                    "krita": "Krita",
                    "com.github.neithern.g4music": "Music",
                    "org.prismlauncher.PrismLauncher": "Prism Launcher",
                    "aseprite": "Aseprite",
                    "obsidian": "Obsidian",
                    "vesktop": "Discord"
                };
                windowCapsule.activeWindow = names[appId] ?? appId;
            }
        }
        Component.onCompleted: running = true
    }

    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: windowProc.running = true
    }
}