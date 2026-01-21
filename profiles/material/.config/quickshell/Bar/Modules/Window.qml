import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.Bar

// Active window title (niri reimplementation)
Item {
    property string activeWindow: "Window"
    Process {
        id: windowProc
        command: ["sh", "-c", "niri msg focused-window | grep 'App ID:' | awk -F '\"' '{print $2}'"]
        stdout: SplitParser {
            onRead: data => {
                if (data && data.trim()) {
                    var appId = data.trim();
                    switch (appId) {
                    case "kitty":
                        activeWindow = "Terminal";
                        break;
                    case "librewolf":
                        activeWindow = "LibreWolf";
                        break;
                    case "dev.zed.Zed":
                        activeWindow = "Zed";
                        break;
                    case "org.gnome.Nautilus":
                        activeWindow = "Files";
                        break;
                    case "org.vinegarhq.Sober":
                        activeWindow = "Roblox";
                        break;
                    case "spotify":
                        activeWindow = "Spotify";
                        break;
                    case "steam":
                        activeWindow = "Steam";
                        break;
                    case "krita":
                        activeWindow = "Krita";
                        break;
                    case "com.github.neithern.g4music":
                        activeWindow = "Music";
                        break;
                    case "org.prismlauncher.PrismLauncher":
                        activeWindow = "Prism Launcher";
                        break;
                    case "aseprite":
                        activeWindow = "Aseprite";
                        break;
                    case "obsidian":
                        activeWindow = "Obsidian";
                        break;
                    case "vesktop":
                        activeWindow = "Discord";
                        break;
                    default:
                        activeWindow = appId;
                    }
                }
            }
        }
        Component.onCompleted: running = true
    }

    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            windowProc.running = true;
        }
    }

    Capsule {
        width: activeWindowText.implicitWidth + Config.capsuleMargin

        Text {
            id: activeWindowText
            text: activeWindow
            color: Config.fontColorSecondary
            font.pixelSize: Config.fontSizeNormal
            font.family: Config.fontFamily
            font.bold: true
            anchors.centerIn: parent
        }
    }
}
