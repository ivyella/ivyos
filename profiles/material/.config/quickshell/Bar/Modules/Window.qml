import Quickshell
import Quickshell.Io
import QtQuick
import qs.Bar
import qs.Common

Rectangle {
    id: windowCapsule
    color: Colors.surfaceContainerHigh
    radius: Metrics.radiusLg
    height: Metrics.controlHeightSm
    implicitWidth: activeWindowText.implicitWidth + Metrics.paddingMd * 2

    property string activeWindow: ""

    Text {
        id: activeWindowText
        anchors.centerIn: parent
        text: windowCapsule.activeWindow
        color: Config.fontColorPrimary
        font.pixelSize: Config.fontSizeNormal
        font.family: Config.fontFamily
        font.weight: 600
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